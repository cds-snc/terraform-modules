"""
Adopted from https://github.com/terraform-aws-modules/terraform-aws-notify-slack
under Apache 2.0 license
"""

from __future__ import print_function

import json
import logging
import os

import urllib.parse
import urllib.request

from urllib.error import HTTPError


def cloudwatch_notification(message, region):
    "Create the CloudWatch notification payload"
    states = {"OK": "good", "INSUFFICIENT_DATA": "warning", "ALARM": "danger"}
    cloudwatch_url = "https://console.aws.amazon.com/cloudwatch/home?region="

    return {
        "color": states[message["NewStateValue"]],
        "fallback": f"Alarm {message['AlarmName']} triggered",
        "fields": [
            {"title": "Name", "value": message["AlarmName"], "short": True},
            {
                "title": "Description",
                "value": message["AlarmDescription"],
                "short": False,
            },
            {"title": "Reason", "value": message["NewStateReason"], "short": False},
            {"title": "Old State", "value": message["OldStateValue"], "short": True},
            {
                "title": "Current State",
                "value": message["NewStateValue"],
                "short": True,
            },
            {
                "title": "Link to Alarm",
                "value": cloudwatch_url
                + region
                + "#alarm:alarmFilter=ANY;name="
                + urllib.parse.quote(message["AlarmName"]),
                "short": False,
            },
        ],
    }


def default_notification(subject, message):
    "Create the default notification payload"
    attachments = {
        "fallback": "A new message",
        "title": subject if subject else "Message",
        "mrkdwn_in": ["value"],
        "fields": [],
    }
    if isinstance(message, dict):
        for msg_key, msg_value in message.items():
            value = (
                f"`{json.dumps(msg_value)}`"
                if isinstance(msg_value, (dict, list))
                else str(msg_value)
            )
            attachments["fields"].append(
                {"title": msg_key, "value": value, "short": len(value) < 25}
            )
    else:
        attachments["fields"].append({"value": message, "short": False})

    return attachments


def notify_slack(subject, message, region):
    "Send a message to a slack channel"
    project_name = os.environ["PROJECT_NAME"]
    slack_url = os.environ["SLACK_WEBHOOK_URL"]
    icons = {"OK": ":green:", "INSUFFICIENT_DATA": ":grey_question:", "ALARM": ":red:"}

    payload = {"attachments": []}

    if isinstance(message, str):
        try:
            message = json.loads(message)
        except json.JSONDecodeError as err:
            logging.exception("JSON decode error: %s", err)

    if "AlarmName" in message:
        notification = cloudwatch_notification(message, region)
        state = message["NewStateValue"]
        payload["text"] = f"{icons[state]} *{state}* {project_name}"
        payload["attachments"].append(notification)
    elif "attachments" in message or "text" in message:
        payload = {**payload, **message}
    else:
        payload["text"] = "AWS notification"
        payload["attachments"].append(default_notification(subject, message))

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(slack_url)
    req.add_header("Content-Type", "application/json")

    try:
        with urllib.request.urlopen(req, data) as result:
            return json.dumps(
                {"code": result.getcode(), "info": result.info().as_string()}
            )

    except HTTPError as http_error:
        logging.error("%s: result", http_error)
        return json.dumps(
            {"code": http_error.getcode(), "info": http_error.info().as_string()}
        )


def lambda_handler(event, context):
    "Lambda function handler invoked by the SNS topic"
    if "LOG_EVENTS" in os.environ and os.environ["LOG_EVENTS"] == "True":
        logging.warning("Event logging enabled: `%s`", json.dumps(event))

    subject = event["Records"][0]["Sns"]["Subject"]
    message = event["Records"][0]["Sns"]["Message"]
    region = event["Records"][0]["Sns"]["TopicArn"].split(":")[3]
    response = notify_slack(subject, message, region)

    if json.loads(response)["code"] != 200:
        logging.error(
            "Error: received status `%s` using event `%s` and context `%s`",
            json.loads(response)["info"],
            event,
            context,
        )

    return response
