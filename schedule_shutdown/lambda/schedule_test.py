import pytest
import unittest
from unittest.mock import patch, MagicMock
import os
import boto3
import schedule


@patch("boto3.client")
@patch("schedule.ecs_service_scale")
@patch("schedule.rds_cluster_scale")
def test_handler(mock_rds_cluster_scale, mock_ecs_service_scale, mock_client):
    event = {"action": "startup"}
    context = None

    with patch("schedule.ECS_SERVICES", new=["arn1", "arn2", "arn3"]), patch(
        "schedule.RDS_CLUSTERS", new=["arn1", "arn2"]
    ):
        schedule.handler(event, context)
        assert mock_ecs_service_scale.call_count == 3
        assert mock_rds_cluster_scale.call_count == 2


@patch("boto3.client")
def test_handler_invalid_action(mock_client):
    event = {"action": "invalid"}
    context = {}

    with pytest.raises(ValueError):
        schedule.handler(event, context)

    mock_client.assert_not_called()


@pytest.mark.parametrize(
    "action, desired_count",
    [
        ("shutdown", 0),
        ("startup", 1),
    ],
)
@patch("boto3.client")
def test_ecs_service_scale(mock_client, action, desired_count):
    service_arn = "arn:aws:ecs:ca-central-1:123456789012:service/my-cluster/my-service"
    schedule.ecs_service_scale(mock_client, service_arn, action)
    mock_client.update_service.assert_called_with(
        cluster="my-cluster",
        service="my-service",
        desiredCount=desired_count,
    )


@pytest.mark.parametrize(
    "action, function_name",
    [
        ("shutdown", "stop_db_cluster"),
        ("startup", "start_db_cluster"),
    ],
)
@patch("boto3.client")
def test_rds_cluster_scale(mock_client, action, function_name):
    cluster_arn = "arn:aws:rds:ca-central-1:123456789012:cluster:my-cluster"
    schedule.rds_cluster_scale(mock_client, cluster_arn, action)
    getattr(mock_client, function_name).assert_called_with(
        DBClusterIdentifier="my-cluster"
    )
