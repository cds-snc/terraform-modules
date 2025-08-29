"""
This Lambda function queries the WAF logs in Amazon Athena and updates the 
WAF IP set with the IP addresses that have met the BLOCK threshold in the 
last 24 hours.
"""

import os
import time
import boto3
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Required
ATHENA_OUTPUT_BUCKET = os.environ["ATHENA_OUTPUT_BUCKET"]
ATHENA_REGION = os.environ["ATHENA_REGION"]
ATHENA_WORKGROUP = os.environ["ATHENA_WORKGROUP"]
WAF_IP_SET_ID = os.environ["WAF_IP_SET_ID"]
WAF_IP_SET_NAME = os.environ["WAF_IP_SET_NAME"]

# Optional
ATHENA_DATABASE = os.getenv("ATHENA_DATABASE", "access_logs")
ATHENA_LB_TABLE = os.getenv("ATHENA_LB_TABLE", "lb_logs")
ATHENA_WAF_TABLE = os.getenv("ATHENA_WAF_TABLE", "waf_logs")
BLOCK_THRESHOLD = os.getenv("BLOCK_THRESHOLD", "20")
LB_STATUS_CODE_SKIP = os.getenv("LB_STATUS_CODE_SKIP", "").split(",")
QUERY_LB = os.getenv("QUERY_LB", "true") == "true"
QUERY_WAF = os.getenv("QUERY_WAF", "true") == "true"
WAF_RULE_IDS_SKIP = os.getenv("WAF_RULE_IDS_SKIP", "").split(",")
WAF_SCOPE = os.getenv("WAF_SCOPE", "REGIONAL")

athena_client = boto3.client("athena", region_name=ATHENA_REGION)
waf_client = boto3.client("wafv2")


def handler(_event, _context):
    """Query the WAF and LB logs and update the WAF IP set with the new IPs"""
    query_lb = get_query_from_file(
        "./query_lb.sql", ATHENA_LB_TABLE, LB_STATUS_CODE_SKIP, BLOCK_THRESHOLD
    )
    query_waf = get_query_from_file(
        "./query_waf.sql", ATHENA_WAF_TABLE, WAF_RULE_IDS_SKIP, BLOCK_THRESHOLD
    )

    ip_addresses = set()
    queries_to_execute = [
        (QUERY_LB, query_lb),
        (QUERY_WAF, query_waf),
    ]
    for do_query, query in queries_to_execute:
        if do_query:
            query_execution_id = start_athena_query(
                query, ATHENA_DATABASE, ATHENA_OUTPUT_BUCKET, ATHENA_WORKGROUP
            )
            ip_addresses.update(get_query_results(query_execution_id))
            print(f"Found following {ip_addresses}")

    if ip_addresses:
        update_waf_ip_set(
            sorted(ip_addresses), WAF_IP_SET_NAME, WAF_IP_SET_ID, WAF_SCOPE
        )


def get_query_from_file(file_path, log_table, skip_list, block_threshold):
    """Read the query from a file"""
    with open(file_path, "r", encoding="utf-8") as file:
        query_template = file.read()
        joined_skip_list = ",".join([f"'{item}'" for item in skip_list])
        query = query_template.format(
            log_table=log_table,
            skip_list=joined_skip_list,
            block_threshold=block_threshold,
        )
        print(query)
        return query


def start_athena_query(query, athena_database, athena_output_bucket, athena_workgroup):
    """Start Athena query execution"""
    response = athena_client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={"Database": athena_database},
        ResultConfiguration={"OutputLocation": f"s3://{athena_output_bucket}/"},
        WorkGroup=athena_workgroup,
    )
    return response["QueryExecutionId"]


def get_query_results(query_execution_id):
    """Poll Athena query and retrieve results when available"""
    status = "RUNNING"
    timeout = 120
    while status in ["RUNNING", "QUEUED"]:
        response = athena_client.get_query_execution(
            QueryExecutionId=query_execution_id
        )
        status = response["QueryExecution"]["Status"]["State"]
        if status in ["FAILED", "CANCELLED"]:
            raise RuntimeError(
                f"Query failed: {response['QueryExecution']['Status']['StateChangeReason']}"
            )

        if status == "SUCCEEDED":
            break

        print(f"Query status: {status}, will wait another {timeout} seconds...")
        time.sleep(2)

        timeout -= 2
        if timeout < 0:
            raise RuntimeError("Athena query timed out")

    # Fetch results
    result = athena_client.get_query_results(QueryExecutionId=query_execution_id)
    ip_addresses = []
    for row in result["ResultSet"]["Rows"][1:]:  # Skip header
        ip_addresses.append(row["Data"][0]["VarCharValue"])

    return ip_addresses


def update_waf_ip_set(ip_addresses, waf_ip_set_name, waf_ip_set_id, waf_scope):
    """Update the WAF IP set with the given IP addresses"""
    # Get the current IP set
    response = waf_client.get_ip_set(
        Name=waf_ip_set_name, Scope=waf_scope, Id=waf_ip_set_id
    )

    # Truncate the IP address list if it has more than 10,000 addresses.
    # This is the max number of addresses an IP set can hold.
    if len(ip_addresses) > 10000:
        print(f"Reducing {len(ip_addresses)} address to 10,000 addresses.")
        ip_addresses = ip_addresses[:10000]

    # Remove any ip addresses known to be owned by the Government of Canada
    ip_addresses = [ip for ip in ip_addresses if not gc_ip(ip)]

    # Check if new addresses have been added to the list of existing addresses.
    # This is useful to monitor the number of new IPs added to the blocklist
    # and to set up alarms if the number of new IPs added is too high
    existing_addresses = response["IPSet"]["Addresses"]
    new_addresses = [f"{ip}/32" for ip in ip_addresses]

    new_ips = 0

    for ip in new_addresses:
        if ip not in existing_addresses:
            # Do not modify message below as it is used to drive a cloudwatch metric
            print("[Metric] - New IP added to WAF IP Set")
            new_ips += 1

    # Update the IP set with new addresses
    waf_client.update_ip_set(
        Name=waf_ip_set_name,
        Scope=waf_scope,
        Id=waf_ip_set_id,
        Addresses=new_addresses,
        LockToken=response["LockToken"],
    )

    print(
        f"Updated WAF IP set with {new_ips} new IPs for a total of {len(ip_addresses)} blocked IPs."
    )


def recursive_entity_search(data):
    """Recursively search through a list of entities to see if one matches GoC"""
    if isinstance(data, list):
        registrants = [d for d in data if "registrant" in d.get("roles", [])]
        top_level_result = any(
            entity.get("handle") == "SSC-299" for entity in registrants
        )
        if not top_level_result:
            # Go deeper and see if there are any other entities associated with this record
            for entity in registrants:
                top_level_result = top_level_result or recursive_entity_search(entity)
                # short circuit once we hit a positive identification
                if top_level_result:
                    return top_level_result
        return top_level_result
    if isinstance(data, dict) and "entities" in data:
        return recursive_entity_search(data["entities"])
    return False


def create_retrying_request(
    total_retries=3,
    backoff_factor=0.5,
    status_forcelist=(500, 502, 503, 504),
    allowed_methods=("GET"),
):
    """
    Creates a requests session with retry logic.
    """
    retry_strategy = Retry(
        total=total_retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
        allowed_methods=allowed_methods,
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session = requests.Session()
    session.mount("https://", adapter)
    return session


def gc_ip(ip):
    """Check if IP is owned by Government of Canada"""
    session = create_retrying_request(total_retries=5, backoff_factor=1)
    try:
        api_url = f"https://rdap.arin.net/registry/ip/{ip}"
        is_gc_ip = False
        response = session.get(api_url, timeout=5)
        if response.ok:
            record = response.json().get("entities")
            if record is not None:
                is_gc_ip = recursive_entity_search(record)
        return is_gc_ip
    except requests.exceptions.RequestException:
        print(f"Could not successfully retrieve information about IP {ip}")
        return False
