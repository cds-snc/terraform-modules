"""
This Lambda function queries the WAF logs in Amazon Athena and updates the 
WAF IP set with the IP addresses that have met the BLOCK threshold in the 
last 24 hours.
"""

import os
import time
import boto3

athena_client = boto3.client("athena")
waf_client = boto3.client("wafv2")

# Required
ATHENA_OUTPUT_BUCKET = os.environ["ATHENA_OUTPUT_BUCKET"]
WAF_IP_SET_ID = os.environ["WAF_IP_SET_ID"]
WAF_IP_SET_NAME = os.environ["WAF_IP_SET_NAME"]

# Optional
ATHENA_DATABASE = os.getenv("ATHENA_DATABASE", "access_logs")
ATHENA_TABLE = os.getenv("ATHENA_TABLE", "waf_logs")
BLOCK_THRESHOLD = os.getenv("BLOCK_THRESHOLD", "20")
WAF_RULE_IDS_SKIP = os.getenv("WAF_RULE_IDS_SKIP", "").split(",")
WAF_SCOPE = os.getenv("WAF_SCOPE", "REGIONAL")


def handler(_event, _context):
    """Query the WAF logs and update the WAF IP set with the new IPs"""
    query = get_query_from_file(
        "./query.sql", ATHENA_TABLE, WAF_RULE_IDS_SKIP, BLOCK_THRESHOLD
    )
    query_execution_id = start_athena_query(
        query, ATHENA_DATABASE, ATHENA_OUTPUT_BUCKET
    )
    ip_addresses = get_query_results(query_execution_id)

    if ip_addresses:
        update_waf_ip_set(ip_addresses, WAF_IP_SET_NAME, WAF_IP_SET_ID, WAF_SCOPE)


def get_query_from_file(file_path, waf_logs_table, waf_rule_ids_skip, block_threshold):
    """Read the query from a file"""
    with open(file_path, "r", encoding="utf-8") as file:
        query_template = file.read()
        joined_rule_ids = ",".join([f"'{rule_id}'" for rule_id in waf_rule_ids_skip])
        query = query_template.format(
            waf_logs_table=waf_logs_table,
            waf_rule_ids_skip=joined_rule_ids,
            block_threshold=block_threshold,
        )
        print(query)
        return query


def start_athena_query(query, athena_database, athena_output_bucket):
    """Start Athena query execution"""
    response = athena_client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={"Database": athena_database},
        ResultConfiguration={"OutputLocation": f"s3://{athena_output_bucket}/"},
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

    # Update the IP set with new addresses
    waf_client.update_ip_set(
        Name=waf_ip_set_name,
        Scope=waf_scope,
        Id=waf_ip_set_id,
        Addresses=[f"{ip}/32" for ip in ip_addresses],
        LockToken=response["LockToken"],
    )

    print(f"Updated WAF IP set with {len(ip_addresses)} new IPs.")