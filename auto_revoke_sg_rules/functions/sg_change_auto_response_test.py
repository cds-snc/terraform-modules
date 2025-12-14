import unittest

from unittest.mock import patch, MagicMock


class TestSgChangeAutoResponse(unittest.TestCase):
    def test_lambda_handler_no_detail(self):
        """Test lambda_handler with event missing 'detail' key"""
        event = {"foo": "bar"}

        import sg_change_auto_response

        result = sg_change_auto_response.lambda_handler(event, None)

        assert result == {
            "Result": "Failure",
            "Message": "Lambda not triggered by an event",
        }

    def test_lambda_handler_no_event_name(self):
        """Test lambda_handler with event missing 'eventName' in detail"""
        event = {"detail": {}}

        import sg_change_auto_response

        result = sg_change_auto_response.lambda_handler(event, None)

        assert result == {
            "Result": "Failure",
            "Message": "Lambda not triggered by an event",
        }

    def test_lambda_handler_wrong_event_name(self):
        """Test lambda_handler with wrong event name"""
        event = {"detail": {"eventName": "SomeOtherEvent"}}

        import sg_change_auto_response

        result = sg_change_auto_response.lambda_handler(event, None)

        # Should return None (no action taken)
        assert result is None

    def test_lambda_handler_ssh_ingress_authorized(self):
        """Test lambda_handler with SSH ingress authorization event"""
        event = {
            "detail": {
                "eventName": "AuthorizeSecurityGroupIngress",
                "userIdentity": {"arn": "arn:aws:iam::123456789012:user/test-user"},
                "requestParameters": {
                    "groupId": "sg-12345678",
                    "ipPermissions": {
                        "items": [
                            {
                                "ipProtocol": "tcp",
                                "fromPort": 22,
                                "toPort": 22,
                                "ipRanges": {"items": [{"cidrIp": "0.0.0.0/0"}]},
                            }
                        ]
                    },
                },
            }
        }

        with (
            patch.dict(
                "os.environ",
                {"sns_topic_arn": "arn:aws:sns:ca-central-1:123456789012:test-topic"},
            ),
            patch("boto3.client") as mock_boto3_client,
        ):
            mock_ec2_client = MagicMock()
            mock_sns_client = MagicMock()

            def client_side_effect(service_name):
                if service_name == "ec2":
                    return mock_ec2_client
                elif service_name == "sns":
                    return mock_sns_client
                return MagicMock()

            mock_boto3_client.side_effect = client_side_effect

            mock_ec2_client.revoke_security_group_ingress.return_value = {}

            import sg_change_auto_response

            sg_change_auto_response.lambda_handler(event, None)

            # Verify EC2 revoke was called
            mock_ec2_client.revoke_security_group_ingress.assert_called_once()
            call_kwargs = mock_ec2_client.revoke_security_group_ingress.call_args[1]
            assert call_kwargs["GroupId"] == "sg-12345678"
            assert len(call_kwargs["IpPermissions"]) == 1
            assert call_kwargs["IpPermissions"][0]["FromPort"] == 22
            assert call_kwargs["IpPermissions"][0]["ToPort"] == 22

            # Verify SNS publish was called
            mock_sns_client.publish.assert_called_once()
            publish_kwargs = mock_sns_client.publish.call_args[1]
            assert (
                publish_kwargs["TargetArn"]
                == "arn:aws:sns:ca-central-1:123456789012:test-topic"
            )
            assert "sg-12345678" in publish_kwargs["Message"]
            assert "test-user" in publish_kwargs["Message"]
            assert publish_kwargs["Subject"] == "Auto-mitigation successful"

    def test_lambda_handler_rdp_ingress_authorized(self):
        """Test lambda_handler with RDP ingress authorization event"""
        event = {
            "detail": {
                "eventName": "AuthorizeSecurityGroupIngress",
                "userIdentity": {"arn": "arn:aws:iam::123456789012:user/test-user"},
                "requestParameters": {
                    "groupId": "sg-87654321",
                    "ipPermissions": {
                        "items": [
                            {
                                "ipProtocol": "tcp",
                                "fromPort": 3389,
                                "toPort": 3389,
                                "ipRanges": {"items": [{"cidrIp": "192.168.1.0/24"}]},
                            }
                        ]
                    },
                },
            }
        }

        with (
            patch.dict(
                "os.environ",
                {"sns_topic_arn": "arn:aws:sns:ca-central-1:123456789012:test-topic"},
            ),
            patch("boto3.client") as mock_boto3_client,
        ):
            mock_ec2_client = MagicMock()
            mock_sns_client = MagicMock()

            def client_side_effect(service_name):
                if service_name == "ec2":
                    return mock_ec2_client
                elif service_name == "sns":
                    return mock_sns_client
                return MagicMock()

            mock_boto3_client.side_effect = client_side_effect

            mock_ec2_client.revoke_security_group_ingress.return_value = {}

            import sg_change_auto_response

            sg_change_auto_response.lambda_handler(event, None)

            # Verify EC2 revoke was called with RDP port
            mock_ec2_client.revoke_security_group_ingress.assert_called_once()
            call_kwargs = mock_ec2_client.revoke_security_group_ingress.call_args[1]
            assert call_kwargs["GroupId"] == "sg-87654321"
            assert call_kwargs["IpPermissions"][0]["FromPort"] == 3389
            assert call_kwargs["IpPermissions"][0]["ToPort"] == 3389

    def test_lambda_handler_non_ssh_rdp_port(self):
        """Test lambda_handler with non-SSH/RDP port (should not trigger)"""
        event = {
            "detail": {
                "eventName": "AuthorizeSecurityGroupIngress",
                "requestParameters": {
                    "ipPermissions": {"items": [{"fromPort": 80, "toPort": 80}]}
                },
            }
        }

        import sg_change_auto_response

        result = sg_change_auto_response.lambda_handler(event, None)

        # Should return None (no action taken for non-SSH/RDP ports)
        assert result is None

    def test_normalize_parameter_names_ipv4(self):
        """Test normalize_paramter_names with IPv4 ranges"""
        ip_items = [
            {
                "ipProtocol": "tcp",
                "fromPort": 22,
                "toPort": 22,
                "ipRanges": {
                    "items": [{"cidrIp": "10.0.0.0/8"}, {"cidrIp": "192.168.0.0/16"}]
                },
            }
        ]

        import sg_change_auto_response

        result = sg_change_auto_response.normalize_paramter_names(ip_items)

        assert len(result) == 1
        assert result[0]["IpProtocol"] == "tcp"
        assert result[0]["FromPort"] == 22
        assert result[0]["ToPort"] == 22
        assert "IpRanges" in result[0]
        assert len(result[0]["IpRanges"]) == 2
        assert result[0]["IpRanges"][0]["CidrIp"] == "10.0.0.0/8"
        assert result[0]["IpRanges"][1]["CidrIp"] == "192.168.0.0/16"

    def test_normalize_parameter_names_ipv6(self):
        """Test normalize_paramter_names with IPv6 ranges"""
        ip_items = [
            {
                "ipProtocol": "tcp",
                "fromPort": 3389,
                "toPort": 3389,
                "ipv6Ranges": {"items": [{"cidrIpv6": "2001:db8::/32"}]},
            }
        ]

        import sg_change_auto_response

        result = sg_change_auto_response.normalize_paramter_names(ip_items)

        assert len(result) == 1
        assert result[0]["IpProtocol"] == "tcp"
        assert result[0]["FromPort"] == 3389
        assert result[0]["ToPort"] == 3389
        assert "Ipv6Ranges" in result[0]
        assert len(result[0]["Ipv6Ranges"]) == 1
        assert result[0]["Ipv6Ranges"][0]["CidrIpv6"] == "2001:db8::/32"

    def test_revoke_security_group_ingress(self):
        """Test revoke_security_group_ingress function"""
        event_detail = {
            "userIdentity": {"arn": "arn:aws:iam::123456789012:user/test-user"},
            "requestParameters": {
                "groupId": "sg-12345678",
                "ipPermissions": {
                    "items": [
                        {
                            "ipProtocol": "tcp",
                            "fromPort": 22,
                            "toPort": 22,
                            "ipRanges": {"items": [{"cidrIp": "0.0.0.0/0"}]},
                        }
                    ]
                },
            },
        }

        with patch("boto3.client") as mock_boto3_client:
            mock_ec2_client = MagicMock()
            mock_boto3_client.return_value = mock_ec2_client
            mock_ec2_client.revoke_security_group_ingress.return_value = {}

            import sg_change_auto_response

            result = sg_change_auto_response.revoke_security_group_ingress(event_detail)

            assert result["group_id"] == "sg-12345678"
            assert result["user_name"] == "arn:aws:iam::123456789012:user/test-user"
            assert len(result["ip_permissions"]) == 1
            assert result["ip_permissions"][0]["FromPort"] == 22

            mock_ec2_client.revoke_security_group_ingress.assert_called_once()
