"""
Lambda function to start or stop resources based on a schedule.
Currently supports ECS services and RDS clusters.
"""
import os
import boto3

ECS_SERVICE_ARNS = os.getenv("ECS_SERVICE_ARNS")
RDS_CLUSTER_ARNS = os.getenv("RDS_CLUSTER_ARNS")
ECS_SERVICES = ECS_SERVICE_ARNS.split(",") if ECS_SERVICE_ARNS else []
RDS_CLUSTERS = RDS_CLUSTER_ARNS.split(",") if RDS_CLUSTER_ARNS else []


# pylint: disable=unused-argument
def handler(event, context):
    "Lambda handler function"

    # Validate the action
    action = event.get("action")
    if action not in ["startup", "shutdown"]:
        raise ValueError(f"Unknown action {action}")

    # ECS cluster scaling
    if ECS_SERVICES:
        ecs_client = boto3.client("ecs")
        for ecs_arn in ECS_SERVICES:
            ecs_service_scale(ecs_client, ecs_arn, action)

    # RDS cluster scaling
    if RDS_CLUSTERS:
        rds_client = boto3.client("rds")
        for rds_arn in RDS_CLUSTERS:
            rds_cluster_scale(rds_client, rds_arn, action)

    return True


def ecs_service_scale(client, service_arn, action):
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


def rds_cluster_scale(client, cluster_arn, action):
    "Start or stop a given RDS cluster based on the action"
    cluster_name = cluster_arn.split(":")[-1]
    function_name = "stop_db_cluster" if action == "shutdown" else "start_db_cluster"

    print(f"Updating RDS cluster {cluster_name} to {function_name}")
    response = getattr(client, function_name)(DBClusterIdentifier=cluster_name)
    print(f"Scale response: {response}")
