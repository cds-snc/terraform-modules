import tempfile
import os
import json

from unittest.mock import call, patch, Mock, MagicMock

os.environ["AWS_DEFAULT_REGION"] = "ca-central-1"
os.environ["ATHENA_OUTPUT_BUCKET"] = "test_bucket"
os.environ["ATHENA_REGION"] = "ca-central-1"
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
                    {"Data": [{"VarCharValue": "198.103.1.2"}]},
                ]
            }
        },
        {
            "ResultSet": {
                "Rows": [
                    {"Data": [{"VarCharValue": "header"}]},
                    {"Data": [{"VarCharValue": "192.168.1.1"}]},
                    {"Data": [{"VarCharValue": "192.168.1.3"}]},
                    {"Data": [{"VarCharValue": "205.193.1.2"}]},
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
                QueryString="-- List of IP addresses that have triggered 4xx HTTP responses\nSELECT\n    client_ip,\n    COUNT(*) as count\nFROM\n    lb_logs\nWHERE\n    (\n        elb_status_code = 403\n        OR target_status_code LIKE '4__'\n        OR target_status_code LIKE '5__'\n    )\n    AND target_status_code NOT IN ('')\n    AND from_iso8601_timestamp(time) >= date_add('day', -1, current_timestamp)\nGROUP BY\n    client_ip\nHAVING COUNT(*) > 20\nORDER BY count DESC",
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
                QueryString="-- List of IP addresses that have triggered 4xx HTTP responses\nSELECT\n    client_ip,\n    COUNT(*) as count\nFROM\n    lb_logs\nWHERE\n    (\n        elb_status_code = 403\n        OR target_status_code LIKE '4__'\n        OR target_status_code LIKE '5__'\n    )\n    AND target_status_code NOT IN ('')\n    AND from_iso8601_timestamp(time) >= date_add('day', -1, current_timestamp)\nGROUP BY\n    client_ip\nHAVING COUNT(*) > 20\nORDER BY count DESC",
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
                QueryString="-- List of IP addresses that have triggered 4xx HTTP responses\nSELECT\n    client_ip,\n    COUNT(*) as count\nFROM\n    lb_logs\nWHERE\n    (\n        elb_status_code = 403\n        OR target_status_code LIKE '4__'\n        OR target_status_code LIKE '5__'\n    )\n    AND target_status_code NOT IN ('')\n    AND from_iso8601_timestamp(time) >= date_add('day', -1, current_timestamp)\nGROUP BY\n    client_ip\nHAVING COUNT(*) > 20\nORDER BY count DESC",
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


def test_recursive_entity_search_with_list_and_goc_handle():
    """Test recursive_entity_search with a list containing GoC handle"""
    test_data = [
        {"roles": ["registrant"], "handle": "SSC-299"},
        {"roles": ["admin"], "handle": "OTHER-123"},
    ]

    result = blocklist.recursive_entity_search(test_data)
    assert result is True


def test_recursive_entity_search_with_list_without_goc_handle():
    """Test recursive_entity_search with a list not containing GoC handle"""
    test_data = [
        {"roles": ["registrant"], "handle": "OTHER-123"},
        {"roles": ["admin"], "handle": "ANOTHER-456"},
    ]

    result = blocklist.recursive_entity_search(test_data)
    assert result is False


def test_recursive_entity_search_with_nested_entities():
    """Test recursive_entity_search with nested entities containing GoC handle"""
    test_data = [
        {
            "roles": ["registrant"],
            "handle": "OTHER-123",
            "entities": [{"roles": ["registrant"], "handle": "SSC-299"}],
        }
    ]

    result = blocklist.recursive_entity_search(test_data)
    assert result is True


def test_recursive_entity_search_with_dict_containing_entities():
    """Test recursive_entity_search with dict containing entities key"""
    test_data = {"entities": [{"roles": ["registrant"], "handle": "SSC-299"}]}

    result = blocklist.recursive_entity_search(test_data)
    assert result is True


def test_recursive_entity_search_with_empty_list():
    """Test recursive_entity_search with empty list"""
    test_data = []

    result = blocklist.recursive_entity_search(test_data)
    assert result is False


def test_recursive_entity_search_with_none():
    """Test recursive_entity_search with None input"""
    result = blocklist.recursive_entity_search(None)
    assert result is False


def test_recursive_entity_search_with_no_registrants():
    """Test recursive_entity_search with list containing no registrants"""
    test_data = [
        {"roles": ["admin"], "handle": "SSC-299"},
        {"roles": ["tech"], "handle": "OTHER-123"},
    ]

    result = blocklist.recursive_entity_search(test_data)
    assert result is False


def test_recursive_entity_search_with_missing_roles():
    """Test recursive_entity_search with entities missing roles field"""
    test_data = [
        {"handle": "SSC-299"},  # Missing roles field
        {"roles": ["admin"], "handle": "OTHER-123"},
    ]

    result = blocklist.recursive_entity_search(test_data)
    assert result is False


@patch("blocklist.create_retrying_request")
def test_gc_ip_success_with_goc_ip(mock_create_session):
    """Test gc_ip with successful response indicating GoC IP"""
    # Setup mock response
    mock_response = Mock()
    mock_response.ok = True
    mock_response.json.return_value = {
        "entities": [{"roles": ["registrant"], "handle": "SSC-299"}]
    }

    # Setup mock session
    mock_session = Mock()
    mock_session.get.return_value = mock_response
    mock_create_session.return_value = mock_session

    # Test
    result = blocklist.gc_ip("192.168.1.1")

    # Verify
    assert result is True
    mock_create_session.assert_called_once_with(total_retries=5, backoff_factor=1)
    mock_session.get.assert_called_once_with(
        "https://rdap.arin.net/registry/ip/192.168.1.1", timeout=5
    )


@patch("blocklist.create_retrying_request")
def test_gc_ip_success_with_non_goc_ip(mock_create_session):
    """Test gc_ip with successful response indicating non-GoC IP"""
    # Setup mock response
    mock_response = Mock()
    mock_response.ok = True
    mock_response.json.return_value = {
        "entities": [{"roles": ["registrant"], "handle": "OTHER-123"}]
    }

    # Setup mock session
    mock_session = Mock()
    mock_session.get.return_value = mock_response
    mock_create_session.return_value = mock_session

    # Test
    result = blocklist.gc_ip("8.8.8.8")

    # Verify
    assert result is False


@patch("blocklist.create_retrying_request")
def test_gc_ip_http_error(mock_create_session):
    """Test gc_ip with HTTP error response"""
    # Setup mock response
    mock_response = Mock()
    mock_response.ok = False
    mock_response.status_code = 404

    # Setup mock session
    mock_session = Mock()
    mock_session.get.return_value = mock_response
    mock_create_session.return_value = mock_session

    # Test
    result = blocklist.gc_ip("192.168.1.1")

    # Verify
    assert result is False


@patch("blocklist.create_retrying_request")
def test_gc_ip_request_exception(mock_create_session, capsys):
    """Test gc_ip with request exception"""
    # Setup mock session to raise exception
    mock_session = Mock()
    mock_session.get.side_effect = blocklist.requests.exceptions.RequestException(
        "Connection error"
    )
    mock_create_session.return_value = mock_session

    # Test
    result = blocklist.gc_ip("192.168.1.1")

    # Verify
    assert result is False
    captured = capsys.readouterr()
    assert (
        "Could not successfully retrieve information about IP 192.168.1.1"
        in captured.out
    )


@patch("blocklist.create_retrying_request")
def test_gc_ip_no_entities_in_response(mock_create_session):
    """Test gc_ip when response has no entities"""
    # Setup mock response
    mock_response = Mock()
    mock_response.ok = True
    mock_response.json.return_value = {"other_field": "value"}

    # Setup mock session
    mock_session = Mock()
    mock_session.get.return_value = mock_response
    mock_create_session.return_value = mock_session

    # Test
    result = blocklist.gc_ip("192.168.1.1")

    # Verify
    assert result is False


@patch("blocklist.create_retrying_request")
def test_gc_ip_entities_is_none(mock_create_session):
    """Test gc_ip when entities field is None"""
    # Setup mock response
    mock_response = Mock()
    mock_response.ok = True
    mock_response.json.return_value = {"entities": None}

    # Setup mock session
    mock_session = Mock()
    mock_session.get.return_value = mock_response
    mock_create_session.return_value = mock_session

    # Test
    result = blocklist.gc_ip("192.168.1.1")

    # Verify
    assert result is False
