import tempfile
import os

from unittest.mock import patch, MagicMock

os.environ["AWS_DEFAULT_REGION"] = "ca-central-1"
os.environ["ATHENA_OUTPUT_BUCKET"] = "test_bucket"
os.environ["WAF_IP_SET_ID"] = "test_ip_set_id"
os.environ["WAF_IP_SET_NAME"] = "test_ip_set_name"

import blocklist


@patch("blocklist.athena_client")
@patch("blocklist.waf_client")
def test_handler_with_ips_to_block(mock_waf_client, mock_athena_client):
    # Setup
    mock_athena_client.start_query_execution.return_value = {
        "QueryExecutionId": "test_query_id"
    }
    mock_athena_client.get_query_execution.return_value = {
        "QueryExecution": {"Status": {"State": "SUCCEEDED"}}
    }
    mock_athena_client.get_query_results.return_value = {
        "ResultSet": {
            "Rows": [
                {"Data": [{"VarCharValue": "header"}]},
                {"Data": [{"VarCharValue": "192.168.1.1"}]},
                {"Data": [{"VarCharValue": "192.168.1.2"}]},
            ]
        }
    }
    mock_waf_client.get_ip_set.return_value = {"LockToken": "test_lock_token"}

    # Execute
    blocklist.handler(None, None)

    # Verify
    mock_athena_client.start_query_execution.assert_called_once()
    mock_athena_client.get_query_execution.assert_called_once()
    mock_athena_client.get_query_results.assert_called_once()
    mock_waf_client.update_ip_set.assert_called_once_with(
        Name="test_ip_set_name",
        Scope="REGIONAL",
        Id="test_ip_set_id",
        Addresses=["192.168.1.1/32", "192.168.1.2/32"],
        LockToken="test_lock_token",
    )


@patch("blocklist.athena_client")
@patch("blocklist.waf_client")
def test_handler_with_no_ips_to_block(mock_waf_client, mock_athena_client):
    # Setup
    mock_athena_client.start_query_execution.return_value = {
        "QueryExecutionId": "test_query_id"
    }
    mock_athena_client.get_query_execution.return_value = {
        "QueryExecution": {"Status": {"State": "SUCCEEDED"}}
    }
    mock_athena_client.get_query_results.return_value = {
        "ResultSet": {"Rows": [{"Data": [{"VarCharValue": "header"}]}]}
    }

    # Execute
    blocklist.handler(None, None)

    # Verify
    mock_athena_client.start_query_execution.assert_called_once()
    mock_athena_client.get_query_execution.assert_called_once()
    mock_athena_client.get_query_results.assert_called_once()
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
    query_template = "SELECT * FROM {waf_logs_table} WHERE rule_id NOT IN ({waf_rule_ids_skip}) AND count > {block_threshold};"
    with tempfile.NamedTemporaryFile(
        delete=False, mode="w", encoding="utf-8"
    ) as temp_file:
        temp_file.write(query_template)
        temp_file_path = temp_file.name

    waf_logs_table = "test_table"
    waf_rule_ids_skip = ["rule1", "rule2"]
    block_threshold = "10"

    # Execute
    query = blocklist.get_query_from_file(
        temp_file_path, waf_logs_table, waf_rule_ids_skip, block_threshold
    )

    # Verify
    expected_query = "SELECT * FROM test_table WHERE rule_id NOT IN ('rule1','rule2') AND count > 10;"
    assert query == expected_query

    # Cleanup
    os.remove(temp_file_path)


def test_get_query_from_file_with_empty_rule_ids():
    # Setup
    query_template = "SELECT * FROM {waf_logs_table} WHERE rule_id NOT IN ({waf_rule_ids_skip}) AND count > {block_threshold};"
    with tempfile.NamedTemporaryFile(
        delete=False, mode="w", encoding="utf-8"
    ) as temp_file:
        temp_file.write(query_template)
        temp_file_path = temp_file.name

    waf_logs_table = "test_table"
    waf_rule_ids_skip = []
    block_threshold = "10"

    # Execute
    query = blocklist.get_query_from_file(
        temp_file_path, waf_logs_table, waf_rule_ids_skip, block_threshold
    )

    # Verify
    expected_query = "SELECT * FROM test_table WHERE rule_id NOT IN () AND count > 10;"
    assert query == expected_query

    # Cleanup
    os.remove(temp_file_path)


def test_get_query_from_file_with_single_rule_id():
    # Setup
    query_template = "SELECT * FROM {waf_logs_table} WHERE rule_id NOT IN ({waf_rule_ids_skip}) AND count > {block_threshold};"
    with tempfile.NamedTemporaryFile(
        delete=False, mode="w", encoding="utf-8"
    ) as temp_file:
        temp_file.write(query_template)
        temp_file_path = temp_file.name

    waf_logs_table = "test_table"
    waf_rule_ids_skip = ["rule1"]
    block_threshold = "10"

    # Execute
    query = blocklist.get_query_from_file(
        temp_file_path, waf_logs_table, waf_rule_ids_skip, block_threshold
    )

    # Verify
    expected_query = (
        "SELECT * FROM test_table WHERE rule_id NOT IN ('rule1') AND count > 10;"
    )
    assert query == expected_query

    # Cleanup
    os.remove(temp_file_path)
