import pytest
import unittest
from unittest.mock import patch, MagicMock
import os
import boto3
import schedule


@patch("boto3.client")
@patch("schedule.cloudwatch_scale")
@patch("schedule.ecs_scale")
@patch("schedule.rds_scale")
@patch("schedule.route53_scale")
def test_handler(
    mock_route53_scale,
    mock_rds_scale,
    mock_ecs_scale,
    mock_cloudwatch_scale,
    mock_client,
):
    event = {"action": "startup"}
    context = None
    mock_services = {
        "cloudwatch": ["arn1", "arn2"],
        "ecs": ["arn1", "arn2", "arn3"],
        "rds": ["arn1"],
        "route53": None,
    }

    with patch("schedule.SERVICES", new=mock_services):
        schedule.handler(event, context)
        assert mock_cloudwatch_scale.call_count == 2
        assert mock_ecs_scale.call_count == 3
        assert mock_rds_scale.call_count == 1
        assert mock_route53_scale.call_count == 0


def test_get_resource_list():
    assert schedule.get_resource_list(None) is None
    assert schedule.get_resource_list("") is None
    assert schedule.get_resource_list("arn1") == ["arn1"]
    assert schedule.get_resource_list("arn1,arn2") == ["arn1", "arn2"]


@patch("boto3.client")
def test_handler_invalid_action(mock_client):
    event = {"action": "invalid"}
    context = {}

    with pytest.raises(ValueError):
        schedule.handler(event, context)

    mock_client.assert_not_called()


@pytest.mark.parametrize(
    "action, function_name",
    [
        ("shutdown", "disable_alarm_actions"),
        ("startup", "enable_alarm_actions"),
    ],
)
@patch("boto3.client")
def test_cloudwatch_scale(mock_client, action, function_name):
    alarm_arn = "arn:aws:cloudwatch:ca-central-1:123456789012:alarm:FancyAlarm"
    schedule.cloudwatch_scale(mock_client, alarm_arn, action)
    getattr(mock_client, function_name).assert_called_with(AlarmNames=["FancyAlarm"])


@pytest.mark.parametrize(
    "action, desired_count",
    [
        ("shutdown", 0),
        ("startup", 1),
    ],
)
@patch("boto3.client")
def test_ecs_scale(mock_client, action, desired_count):
    service_arn = (
        "arn:aws:ecs:ca-central-1:123456789012:service/some-cluster/with-a-service"
    )
    schedule.ecs_scale(mock_client, service_arn, action)
    mock_client.update_service.assert_called_with(
        cluster="some-cluster",
        service="with-a-service",
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
def test_rds_scale(mock_client, action, function_name):
    cluster_arn = "arn:aws:rds:ca-central-1:123456789012:cluster:so-very-much-data"
    schedule.rds_scale(mock_client, cluster_arn, action)
    getattr(mock_client, function_name).assert_called_with(
        DBClusterIdentifier="so-very-much-data"
    )


@pytest.mark.parametrize(
    "action, disabled",
    [
        ("shutdown", True),
        ("startup", False),
    ],
)
@patch("boto3.client")
def test_route53_scale(mock_client, action, disabled):
    healthcheck_arn = "arn:aws:route53:::healthcheck/mmm-healthy"
    schedule.route53_scale(mock_client, healthcheck_arn, action)
    mock_client.update_health_check.assert_called_with(
        HealthCheckId="mmm-healthy",
        Disabled=disabled,
    )
