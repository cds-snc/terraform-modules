import json
import os
import pytest
import notify_slack
import urllib

from unittest.mock import call, MagicMock, patch

events = (
    (
        {
            "Records": [
                {
                    "Colour": "good",
                    "Icon": ":green:",
                    "EventSource": "aws:sns",
                    "EventVersion": "1.0",
                    "EventSubscriptionArn": "arn:aws:sns:eu-west-2:735598076380:service-updates:d29b4e2c-6840-9c4e-ceac-17128efcc337",
                    "Sns": {
                        "Type": "Notification",
                        "MessageId": "f86e3c5b-cd17-1ab8-80e9-c0776d4f1e7a",
                        "TopicArn": "arn:aws:sns:eu-west-2:735598076380:service-updates",
                        "Subject": "All Fine",
                        "Message": "{\"AlarmName\": \"Example\",\"AlarmDescription\": \"Example alarm description.\",\"AWSAccountId\": \"000000000000\",\"NewStateValue\": \"OK\",\"NewStateReason\": \"Threshold Crossed\",\"StateChangeTime\": \"2017-01-12T16:30:42.236+0000\",\"Region\": \"EU - Ireland\",\"OldStateValue\": \"OK\"}",
                        "Timestamp": "2019-02-12T15:45:24.091Z",
                        "SignatureVersion": "1",
                        "Signature": "WMYdVRN7ECNXMWZ0faRDD4fSfALW5MISB6O//LMd/LeSQYNQ/1eKYEE0PM1SHcH+73T/f/eVHbID/F203VZaGECQTD4LVA4B0DGAEY39LVbWdPTCHIDC6QCBV5ScGFZcROBXMe3UBWWMQAVTSWTE0eP526BFUTecaDFM4b9HMT4NEHWa4A2TA7d888JaVKKdSVNTd4bGS6Q2XFG1MOb652BRAHdARO7A6//2/47JZ5COM6LR0/V7TcOYCBZ20CRF6L5XLU46YYL3I1PNGKbEC1PIeVDVJVPcA17NfUbFXWYBX8LHfM4O7ZbGAPaGffDYLFWM6TX1Y6fQ01OSMc21OdUGV6HQR01e%==",
                        "SigningCertUrl": "https://sns.eu-west-2.amazonaws.com/SimpleNotificationService-7dd85a2b76adaa8dd603b7a0c9150589.pem",
                        "UnsubscribeUrl": "https://sns.eu-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-2:735598076380:service-updates:d29b4e2c-6840-9c4e-ceac-17128efcc337",
                        "MessageAttributes": {}
                    }
                }
            ]
        }
    ),
    (
        {
            "Records": [
                {
                    "Colour": "danger",
                    "Icon": ":red:",
                    "EventSource": "aws:sns",
                    "EventVersion": "1.0",
                    "EventSubscriptionArn": "arn:aws:sns:eu-west-2:735598076380:service-updates:d29b4e2c-6840-9c4e-ceac-17128efcc337",
                    "Sns": {
                        "Type": "Notification",
                        "MessageId": "f86e3c5b-cd17-1ab8-80e9-c0776d4f1e7a",
                        "TopicArn": "arn:aws:sns:eu-west-2:735598076380:service-updates",
                        "Subject": "DMS Notification Message",
                        "Message": "{\"AlarmName\": \"Example\",\"AlarmDescription\": \"Example alarm description.\",\"AWSAccountId\": \"000000000000\",\"NewStateValue\": \"ALARM\",\"NewStateReason\": \"Threshold Crossed\",\"StateChangeTime\": \"2017-01-12T16:30:42.236+0000\",\"Region\": \"EU - Ireland\",\"OldStateValue\": \"OK\"}",
                        "Timestamp": "2019-02-12T15:45:24.091Z",
                        "SignatureVersion": "1",
                        "Signature": "WMYdVRN7ECNXMWZ0faRDD4fSfALW5MISB6O//LMd/LeSQYNQ/1eKYEE0PM1SHcH+73T/f/eVHbID/F203VZaGECQTD4LVA4B0DGAEY39LVbWdPTCHIDC6QCBV5ScGFZcROBXMe3UBWWMQAVTSWTE0eP526BFUTecaDFM4b9HMT4NEHWa4A2TA7d888JaVKKdSVNTd4bGS6Q2XFG1MOb652BRAHdARO7A6//2/47JZ5COM6LR0/V7TcOYCBZ20CRF6L5XLU46YYL3I1PNGKbEC1PIeVDVJVPcA17NfUbFXWYBX8LHfM4O7ZbGAPaGffDYLFWM6TX1Y6fQ01OSMc21OdUGV6HQR01e%==",
                        "SigningCertUrl": "https://sns.eu-west-2.amazonaws.com/SimpleNotificationService-7dd85a2b76adaa8dd603b7a0c9150589.pem",
                        "UnsubscribeUrl": "https://sns.eu-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-2:735598076380:service-updates:d29b4e2c-6840-9c4e-ceac-17128efcc337",
                        "MessageAttributes": {}
                    }
                }
            ]
        }
    ),
    (
      {
        "Records": [
          {
            "Colour": "warning",
            "Icon": ":grey_question:",
            "EventSource": "aws:sns",
            "EventVersion": "1.0",
            "EventSubscriptionArn": "arn:aws:sns:eu-west-1:000000000000:my-sns:76cc1745-b910-4f5e-97bf-f5993b044420",
            "Sns": {
              "Type": "Notification",
              "MessageId": "00337b3f-0982-5cb1-9138-22799c885da9",
              "TopicArn": "arn:aws:sns:eu-west-1:000000000000:my-sns",
              "Subject": None,
              "Message": "{\"AlarmName\": \"Example\",\"AlarmDescription\": \"Example alarm description.\",\"AWSAccountId\": \"000000000000\",\"NewStateValue\": \"INSUFFICIENT_DATA\",\"NewStateReason\": \"Threshold Crossed\",\"StateChangeTime\": \"2017-01-12T16:30:42.236+0000\",\"Region\": \"EU - Ireland\",\"OldStateValue\": \"OK\"}",
              "Timestamp": "2021-06-18T12:34:09.509Z",
              "SignatureVersion": "1",
              "Signature": "MN9H4+7QXISx+IqoRtsdIIXhd9cy9yIV916ajnDChJF9XaPi76zlwHb6RYRdi8MxKIEZsQ7F6DYV/4Hz6GqcQckqZpuYywwa3S1qUim4jw+HKtVvLAsQr/aZ0n2b/8gBC0wPpge3YaMJ13iliJ0G5Bs85MoCrTVG17TGsg8HqJkeKNx1mC4PyOMejXm+F3dwudPLozJ+CX6s+rMkiHVmpJjAv9N2qYgCKloG//dXQEU9LdZpGTDFEnazVR8PKjBEN9RTXNcNnAWuFrt+r0kOtiUoObtJOulPrUIQhIi8fvLto329wWzUQkB9wnvEt7QHeO9Qp8WhstQ3/ki8yiyAwA==",
              "SigningCertUrl": "https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-010a507c1833636cd94bdb98bd93083a.pem",
              "UnsubscribeUrl": "https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:r00000000000:my-sns:76cc1745-b910-4f5e-97bf-f5993b044420",
              "MessageAttributes": {},
            },
          }
        ]
      }
    ),
)


@pytest.mark.parametrize("event", events)
def test_cloudwatch_notification(event):
    cloudwatch_url = "https://console.aws.amazon.com/cloudwatch/home?region="
    message = json.loads(event['Records'][0]['Sns']['Message'])
    colour = event['Records'][0]['Colour']
    region = "ca-central-1"    

    assert notify_slack.cloudwatch_notification(message, "ca-central-1") == {
        "color": colour,
        "fallback": "Alarm {} triggered".format(message['AlarmName']),
        "fields": [
        { "title": "Name", "value": message['AlarmName'], "short": True },
        { "title": "Description", "value": message['AlarmDescription'], "short": False},
        { "title": "Reason", "value": message['NewStateReason'], "short": False},
        { "title": "Old State", "value": message['OldStateValue'], "short": True },
        { "title": "Current State", "value": message['NewStateValue'], "short": True },
        {
            "title": "Link to Alarm",
            "value": cloudwatch_url + region + "#alarm:alarmFilter=ANY;name=" + message['AlarmName'],
            "short": False
        }
        ]
    }


@patch("urllib.request.urlopen")
@patch("urllib.request.Request")
@patch.dict(os.environ, {"PROJECT_NAME": "foo", "SLACK_WEBHOOK_URL": "https://bar.com"}, clear=True)
@pytest.mark.parametrize("event", events)
def test_notify_slack(MockRequest, MockUrlopen, event):
    MockResult = MagicMock()
    MockUrlopen.return_value = MockResult
    MockResult.getcode.return_value = 200
    MockResult.info.return_value.as_string.return_value = "Muffins"
    MockRequest.return_value = "https://bar.com"

    icon = event['Records'][0]['Icon']
    message = json.loads(event['Records'][0]['Sns']['Message'])
    region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]
    subject = event['Records'][0]['Sns']['Subject']    
    payload = {        
        "attachments": [notify_slack.cloudwatch_notification(message, region)],
        "text": f"{icon} *{message['NewStateValue']}* foo",
    }

    data = urllib.parse.urlencode({"payload": json.dumps(payload)}).encode("utf-8")
    response = notify_slack.notify_slack(subject, message, region)

    MockUrlopen.assert_called_with("https://bar.com", data)


@patch("notify_slack.notify_slack")
@pytest.mark.parametrize("event", events)
def test_lambda_handler_success(MockNotifySlack, event):
    MockNotifySlack.return_value = "{\"code\": 200}"
    
    message = event['Records'][0]['Sns']['Message']
    region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]
    subject = event['Records'][0]['Sns']['Subject']

    response = notify_slack.lambda_handler(event, 'self-context')
    notify_slack.notify_slack.assert_called_with(subject, message, region)

    response = json.loads(response)
    assert response['code'] == 200


@patch("notify_slack.notify_slack")
@patch("logging.error")
@pytest.mark.parametrize("event", events)
def test_lambda_handler_fail(MockLoggingError, MockNotifySlack, event):
    MockNotifySlack.return_value = "{\"code\": 404, \"info\": \"failed\"}"

    notify_slack.lambda_handler(event, 'self-context')
    assert MockLoggingError.call_count == 1
