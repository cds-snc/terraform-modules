import tempfile
import os

from unittest.mock import call, patch

os.environ["AWS_DEFAULT_REGION"] = "ca-central-1"
os.environ["ATHENA_OUTPUT_BUCKET"] = "test_bucket"
os.environ["ATHENA_WORKGROUP"] = "test_workgroup"
os.environ["WAF_IP_SET_ID"] = "test_ip_set_id"
os.environ["WAF_IP_SET_NAME"] = "test_ip_set_name"

import blocklist


@patch("blocklist.athena_client")
@patch("blocklist.waf_client")
def test_handler_with_ips_to_block(mock_waf_client, mock_athena_client, capsys):
    # Setup
    mock_athena_client.start_query_execution.side_effect = [
        {"QueryExecutionId": "test_query_lb_id"},
        {"QueryExecutionId": "test_query_waf_id"},
    ]
    mock_athena_client.get_query_execution.return_value = {
        "QueryExecution": {"Status": {"State": "SUCCEEDED"}}
    }
    mock_athena_client.get_query_results.side_effect = [
        {
            "ResultSet": {
                "Rows": [
                    {"Data": [{"VarCharValue": "header"}]},
                    {"Data": [{"VarCharValue": "192.168.1.1"}]},
                    {"Data": [{"VarCharValue": "192.168.1.2"}]},
                ]
            }
        },
        {
            "ResultSet": {
                "Rows": [
                    {"Data": [{"VarCharValue": "header"}]},
                    {"Data": [{"VarCharValue": "192.168.1.1"}]},
                    {"Data": [{"VarCharValue": "192.168.1.3"}]},
                ]
            }
        },
    ]
    mock_waf_client.get_ip_set.return_value = {
        "IPSet": {"Addresses": ["192.168.1.1/32"]},
        "LockToken": "test_lock_token",
    }

    # Execute
    blocklist.handler(None, None)

    # Verify
    mock_athena_client.start_query_execution.assert_has_calls(
        [
            call(
                QueryString="-- List of IP addresses that have triggered 4xx HTTP responses\nSELECT\n    client_ip,\n    COUNT(*) as count\nFROM\n    lb_logs\nWHERE\n    (\n        elb_status_code = 403\n        OR target_status_code LIKE '4__'\n    )\n    AND from_iso8601_timestamp(time) >= date_add('day', -1, current_timestamp)\nGROUP BY\n    client_ip\nHAVING COUNT(*) > 20\nORDER BY count DESC",
                QueryExecutionContext={"Database": "access_logs"},
                ResultConfiguration={"OutputLocation": "s3://test_bucket/"},
                WorkGroup="test_workgroup",
            ),
            call(
                QueryString="-- List of IP addresses that have been blocked by WAF\nSELECT \n    httpRequest.clientIp,\n    COUNT(*) as count\nFROM \n    waf_logs\nWHERE \n    action = 'BLOCK'\n    AND terminatingruleid NOT IN ('') \n    AND from_unixtime(timestamp/1000) >= date_add('day', -1, current_timestamp)\nGROUP BY \n    httpRequest.clientIp\nHAVING COUNT(*) > 20\nORDER BY count DESC",
                QueryExecutionContext={"Database": "access_logs"},
                ResultConfiguration={"OutputLocation": "s3://test_bucket/"},
                WorkGroup="test_workgroup",
            ),
        ]
    )
    mock_athena_client.get_query_execution.assert_has_calls(
        [
            call(QueryExecutionId="test_query_lb_id"),
            call(QueryExecutionId="test_query_waf_id"),
        ]
    )
    mock_athena_client.get_query_results.assert_has_calls(
        [
            call(QueryExecutionId="test_query_lb_id"),
            call(QueryExecutionId="test_query_waf_id"),
        ]
    )
    mock_waf_client.update_ip_set.assert_called_once_with(
        Name="test_ip_set_name",
        Scope="REGIONAL",
        Id="test_ip_set_id",
        Addresses=["192.168.1.1/32", "192.168.1.2/32", "192.168.1.3/32"],
        LockToken="test_lock_token",
    )

    captured = capsys.readouterr()
    all_console_logs = captured.out.split("\n")

    assert all_console_logs.count("[Metric] - New IP added to WAF IP Set") == 2


@patch("blocklist.athena_client")
@patch("blocklist.waf_client")
def test_handler_with_no_ips_to_block(mock_waf_client, mock_athena_client):
    # Setup
    mock_athena_client.start_query_execution.side_effect = [
        {"QueryExecutionId": "test_query_lb_id"},
        {"QueryExecutionId": "test_query_waf_id"},
    ]
    mock_athena_client.get_query_execution.return_value = {
        "QueryExecution": {"Status": {"State": "SUCCEEDED"}}
    }
    mock_athena_client.get_query_results.return_value = {
        "ResultSet": {"Rows": [{"Data": [{"VarCharValue": "header"}]}]}
    }

    # Execute
    blocklist.handler(None, None)

    # Verify
    mock_athena_client.start_query_execution.assert_has_calls(
        [
            call(
                QueryString="-- List of IP addresses that have triggered 4xx HTTP responses\nSELECT\n    client_ip,\n    COUNT(*) as count\nFROM\n    lb_logs\nWHERE\n    (\n        elb_status_code = 403\n        OR target_status_code LIKE '4__'\n    )\n    AND from_iso8601_timestamp(time) >= date_add('day', -1, current_timestamp)\nGROUP BY\n    client_ip\nHAVING COUNT(*) > 20\nORDER BY count DESC",
                QueryExecutionContext={"Database": "access_logs"},
                ResultConfiguration={"OutputLocation": "s3://test_bucket/"},
                WorkGroup="test_workgroup",
            ),
            call(
                QueryString="-- List of IP addresses that have been blocked by WAF\nSELECT \n    httpRequest.clientIp,\n    COUNT(*) as count\nFROM \n    waf_logs\nWHERE \n    action = 'BLOCK'\n    AND terminatingruleid NOT IN ('') \n    AND from_unixtime(timestamp/1000) >= date_add('day', -1, current_timestamp)\nGROUP BY \n    httpRequest.clientIp\nHAVING COUNT(*) > 20\nORDER BY count DESC",
                QueryExecutionContext={"Database": "access_logs"},
                ResultConfiguration={"OutputLocation": "s3://test_bucket/"},
                WorkGroup="test_workgroup",
            ),
        ]
    )
    mock_athena_client.get_query_execution.assert_has_calls(
        [
            call(QueryExecutionId="test_query_lb_id"),
            call(QueryExecutionId="test_query_waf_id"),
        ]
    )
    assert mock_athena_client.get_query_results.call_count == 2
    mock_waf_client.update_ip_set.assert_not_called()


@patch("blocklist.athena_client")
@patch("blocklist.waf_client")
@patch("blocklist.QUERY_WAF", False)
def test_handler_with_only_lb_query(mock_waf_client, mock_athena_client):
    # Setup
    mock_athena_client.start_query_execution.side_effect = [
        {"QueryExecutionId": "test_query_lb_id"},
        {"QueryExecutionId": "test_query_waf_id"},
    ]
    mock_athena_client.get_query_execution.return_value = {
        "QueryExecution": {"Status": {"State": "SUCCEEDED"}}
    }
    mock_athena_client.get_query_results.return_value = {
        "ResultSet": {"Rows": [{"Data": [{"VarCharValue": "header"}]}]}
    }

    # Execute
    blocklist.handler(None, None)

    # Verify
    mock_athena_client.start_query_execution.assert_has_calls(
        [
            call(
                QueryString="-- List of IP addresses that have triggered 4xx HTTP responses\nSELECT\n    client_ip,\n    COUNT(*) as count\nFROM\n    lb_logs\nWHERE\n    (\n        elb_status_code = 403\n        OR target_status_code LIKE '4__'\n    )\n    AND from_iso8601_timestamp(time) >= date_add('day', -1, current_timestamp)\nGROUP BY\n    client_ip\nHAVING COUNT(*) > 20\nORDER BY count DESC",
                QueryExecutionContext={"Database": "access_logs"},
                ResultConfiguration={"OutputLocation": "s3://test_bucket/"},
                WorkGroup="test_workgroup",
            )
        ]
    )
    mock_athena_client.get_query_execution.assert_has_calls(
        [
            call(QueryExecutionId="test_query_lb_id"),
        ]
    )
    assert mock_athena_client.get_query_results.call_count == 1
    mock_waf_client.update_ip_set.assert_not_called()


@patch("blocklist.athena_client")
@patch("blocklist.waf_client")
def test_handler_athena_query_failure(mock_waf_client, mock_athena_client):
    # Setup
    mock_athena_client.start_query_execution.return_value = {
        "QueryExecutionId": "test_query_id"
    }
    mock_athena_client.get_query_execution.return_value = {
        "QueryExecution": {
            "Status": {"State": "FAILED", "StateChangeReason": "Test failure"}
        }
    }

    # Execute & Verify
    try:
        blocklist.handler(None, None)
    except RuntimeError as e:
        assert str(e) == "Query failed: Test failure"

    mock_athena_client.start_query_execution.assert_called_once()
    mock_athena_client.get_query_execution.assert_called_once()
    mock_athena_client.get_query_results.assert_not_called()
    mock_waf_client.update_ip_set.assert_not_called()


def test_get_query_from_file_with_multiple_rule_ids():
    # Setup
    query_template = "SELECT * FROM {log_table} WHERE rule_id NOT IN ({skip_list}) AND count > {block_threshold};"
    with tempfile.NamedTemporaryFile(
        delete=False, mode="w", encoding="utf-8"
    ) as temp_file:
        temp_file.write(query_template)
        temp_file_path = temp_file.name

    log_table = "test_table"
    skip_list = ["rule1", "rule2"]
    block_threshold = "10"

    # Execute
    query = blocklist.get_query_from_file(
        temp_file_path, log_table, skip_list, block_threshold
    )

    # Verify
    expected_query = "SELECT * FROM test_table WHERE rule_id NOT IN ('rule1','rule2') AND count > 10;"
    assert query == expected_query

    # Cleanup
    os.remove(temp_file_path)


def test_get_query_from_file_with_empty_rule_ids():
    # Setup
    query_template = "SELECT * FROM {log_table} WHERE rule_id NOT IN ({skip_list}) AND count > {block_threshold};"
    with tempfile.NamedTemporaryFile(
        delete=False, mode="w", encoding="utf-8"
    ) as temp_file:
        temp_file.write(query_template)
        temp_file_path = temp_file.name

    log_table = "test_table"
    skip_list = []
    block_threshold = "10"

    # Execute
    query = blocklist.get_query_from_file(
        temp_file_path, log_table, skip_list, block_threshold
    )

    # Verify
    expected_query = "SELECT * FROM test_table WHERE rule_id NOT IN () AND count > 10;"
    assert query == expected_query

    # Cleanup
    os.remove(temp_file_path)


def test_get_query_from_file_with_single_rule_id():
    # Setup
    query_template = "SELECT * FROM {log_table} WHERE rule_id NOT IN ({skip_list}) AND count > {block_threshold};"
    with tempfile.NamedTemporaryFile(
        delete=False, mode="w", encoding="utf-8"
    ) as temp_file:
        temp_file.write(query_template)
        temp_file_path = temp_file.name

    log_table = "test_table"
    skip_list = ["rule1"]
    block_threshold = "10"

    # Execute
    query = blocklist.get_query_from_file(
        temp_file_path, log_table, skip_list, block_threshold
    )

    # Verify
    expected_query = (
        "SELECT * FROM test_table WHERE rule_id NOT IN ('rule1') AND count > 10;"
    )
    assert query == expected_query

    # Cleanup
    os.remove(temp_file_path)
