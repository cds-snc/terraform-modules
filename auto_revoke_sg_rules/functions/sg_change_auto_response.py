"""Lambda function to automatically revoke security group ingress rules."""

import os
import json
import boto3


# ===============================================================================
def lambda_handler(event, _context):
    """Handle Lambda invocation to revoke security group ingress rules."""

    # Ensure that we have an event name to evaluate.
    if "detail" not in event or (
        "detail" in event and "eventName" not in event["detail"]
    ):
        return {"Result": "Failure", "Message": "Lambda not triggered by an event"}

    # Remove the rule only if the event was to authorize the ingress rule for the given
    # security group that was injected during CloudFormation execution.
    if event["detail"]["eventName"] == "AuthorizeSecurityGroupIngress" and any(
        (
            (d["fromPort"] == 22 and d["toPort"] == 22)
            or (d["fromPort"] == 3389 and d["toPort"] == 3389)
        )
        for d in event["detail"]["requestParameters"]["ipPermissions"]["items"]
    ):
        result = revoke_security_group_ingress(event["detail"])

        message = (
            f"AUTO-MITIGATED: Ingress rule removed from security group: "
            f"{result['group_id']} that was added by {result['user_name']}: "
            f"{json.dumps(result['ip_permissions'])}"
        )

        boto3.client("sns").publish(
            TargetArn=os.environ["sns_topic_arn"],
            Message=message,
            Subject="Auto-mitigation successful",
        )

    return None


# ===============================================================================
def revoke_security_group_ingress(event_detail):
    """Revoke security group ingress rule based on event details."""
    request_parameters = event_detail["requestParameters"]

    # Build the normalized IP permission JSON struture.
    ip_permissions = normalize_paramter_names(
        request_parameters["ipPermissions"]["items"]
    )

    boto3.client("ec2").revoke_security_group_ingress(
        GroupId=request_parameters["groupId"], IpPermissions=ip_permissions
    )

    # Build the result
    result = {}
    result["group_id"] = request_parameters["groupId"]
    result["user_name"] = event_detail["userIdentity"]["arn"]
    result["ip_permissions"] = ip_permissions

    return result


# ===============================================================================
def normalize_paramter_names(ip_items):
    """Normalize parameter names from CloudWatch event format to EC2 API format."""
    # Start building the permissions items list.
    new_ip_items = []

    # First, build the basic parameter list.
    for ip_item in ip_items:

        new_ip_item = {
            "IpProtocol": ip_item["ipProtocol"],
            "FromPort": ip_item["fromPort"],
            "ToPort": ip_item["toPort"],
        }

        # CidrIp or CidrIpv6 (IPv4 or IPv6)?
        if "ipv6Ranges" in ip_item and ip_item["ipv6Ranges"]:
            # This is an IPv6 permission range, so change the key names.
            ipv_range_list_name = "ipv6Ranges"
            ipv_address_value = "cidrIpv6"
            ipv_range_list_name_capitalized = "Ipv6Ranges"
            ipv_address_value_capitalized = "CidrIpv6"
        else:
            ipv_range_list_name = "ipRanges"
            ipv_address_value = "cidrIp"
            ipv_range_list_name_capitalized = "IpRanges"
            ipv_address_value_capitalized = "CidrIp"

        ip_ranges = []

        # Next, build the IP permission list.
        for item in ip_item[ipv_range_list_name]["items"]:
            ip_ranges.append({ipv_address_value_capitalized: item[ipv_address_value]})

        new_ip_item[ipv_range_list_name_capitalized] = ip_ranges

        new_ip_items.append(new_ip_item)

    return new_ip_items
