"""
Lambda function to start or stop resources based on a schedule.
Currently supports ECS services and RDS clusters.
"""
import os
import boto3


def get_resource_list(resources):
    "Get a list of resources from the comma delimited string"
    return resources.split(",") if resources else None


# The key is the service's client name in boto3
# A "{service}_scale" method should exist to handle the shutdown/startup
SERVICES = {
    "cloudwatch": get_resource_list(os.getenv("CLOUDWATCH_ALARM_ARNS")),
    "ecs": get_resource_list(os.getenv("ECS_SERVICE_ARNS")),
    "rds": get_resource_list(os.getenv("RDS_CLUSTER_ARNS")),
    "route53": get_resource_list(os.getenv("ROUTE53_HEALTHCHECK_ARNS")),
}


# pylint: disable=unused-argument
def handler(event, context):
    "Lambda handler responsible for starting or stopping resources"

    # Validate the action
    action = event.get("action")
    if action not in ["startup", "shutdown"]:
        raise ValueError(f"Unknown action {action}")

    for service, resources in SERVICES.items():
        if resources:
            client = boto3.client(service)
            for resource in resources:
                globals()[f"{service}_scale"](client, resource, action)

    return True


def cloudwatch_scale(client, alarm_arn, action):
    "Enable or disable a given CloudWatch alarm's actions based on the action"
    alarm_name = alarm_arn.split(":")[-1]
    function_name = (
        "disable_alarm_actions" if action == "shutdown" else "enable_alarm_actions"
    )

    print(f"Updating CloudWatch alarm {alarm_name} to {function_name}")
    response = getattr(client, function_name)(AlarmNames=[alarm_name])
    print(f"Scale response: {response}")


def ecs_scale(client, service_arn, action):
    "Scale a given ECS service to a desired count"
    desired_count = 0 if action == "shutdown" else 1
    cluster_name = service_arn.split("/")[1]
    service_name = service_arn.split("/")[2]

    print(f"Scaling ECS service {cluster_name}/{service_name} to {desired_count}")
    response = client.update_service(
        cluster=cluster_name,
        service=service_name,
        desiredCount=desired_count,
    )
    print(f"Scale response: {response}")


def rds_scale(client, cluster_arn, action):
    "Start or stop a given RDS cluster based on the action"
    cluster_name = cluster_arn.split(":")[-1]
    function_name = "stop_db_cluster" if action == "shutdown" else "start_db_cluster"

    print(f"Updating RDS cluster {cluster_name} to {function_name}")
    response = getattr(client, function_name)(DBClusterIdentifier=cluster_name)
    print(f"Scale response: {response}")


def route53_scale(client, healthcheck_arn, action):
    "Enable or disable a given Route53 health check based on the action"
    healthcheck_id = healthcheck_arn.split("/")[-1]
    disabled = action == "shutdown"
    print(f"Setting Route53 healthcheck {healthcheck_id} Disabled={disabled}")
    response = client.update_health_check(
        HealthCheckId=healthcheck_id, Disabled=disabled
    )
    print(f"Scale response: {response}")
