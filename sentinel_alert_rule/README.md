
This module deploys an analytic rule to Azure Sentinel.

You'll need to provide the following:
- Log Analytics Workspace ID
- Query
- Query Frequency
- Query Period
- Severity
- Tactics
- Trigger Operator
- Trigger Threshold
- Entity Mapping
- Incident Configuration

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_sentinel_alert_rule_scheduled.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_alert_rule_scheduled) | resource |
| [random_uuid.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_details"></a> [custom\_details](#input\_custom\_details) | (Optional) The custom details of the alert rule. | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | (Required) The description of the alert rule. | `string` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Required) The display name of the alert rule. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | (Optional) The enabled status of the alert rule. Defaults to true. | `bool` | `true` | no |
| <a name="input_entity_mapping"></a> [entity\_mapping](#input\_entity\_mapping) | (Optional) The entity mapping of the alert rule. | <pre>list(object({<br/>    entity_type = string<br/>    field_mapping = list(object({<br/>      column_name = string<br/>      identifier  = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_event_grouping"></a> [event\_grouping](#input\_event\_grouping) | (Optional) The event grouping of the alert rule. | `map(string)` | <pre>{<br/>  "aggregation_method": "AlertPerResult"<br/>}</pre> | no |
| <a name="input_incident_configuration"></a> [incident\_configuration](#input\_incident\_configuration) | (Optional) The incident configuration of the alert rule. | `any` | <pre>{<br/>  "create_incident": true,<br/>  "grouping": {<br/>    "enabled": false,<br/>    "entity_matching_method": "AllEntities",<br/>    "group_by_alert_details": [],<br/>    "group_by_custom_details": [],<br/>    "group_by_entities": [],<br/>    "lookback_duration": "PT5M",<br/>    "reopen_closed_incidents": false<br/>  }<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The name of the azurerm\_sentinel\_alert\_rule\_scheduled. If not provided, a random UUID will be used. | `string` | `""` | no |
| <a name="input_query"></a> [query](#input\_query) | (Required) The query that will be used to create the alert rule. | `string` | n/a | yes |
| <a name="input_query_frequency"></a> [query\_frequency](#input\_query\_frequency) | (Optional) The frequency of the query. Defaults to PT1H. | `string` | `"PT1H"` | no |
| <a name="input_query_period"></a> [query\_period](#input\_query\_period) | (Optional) The period of the query. Defaults to PT1H. | `string` | `"PT1H"` | no |
| <a name="input_severity"></a> [severity](#input\_severity) | (Optional) The severity of the alert rule. Defaults to Medium. | `string` | `"Medium"` | no |
| <a name="input_suppression_duration"></a> [suppression\_duration](#input\_suppression\_duration) | (Optional) The suppression duration of the alert rule. Defaults to PT1H. | `string` | `"PT1H"` | no |
| <a name="input_suppression_enabled"></a> [suppression\_enabled](#input\_suppression\_enabled) | (Optional) The suppression enabled of the alert rule. Defaults to false. | `bool` | `false` | no |
| <a name="input_tactics"></a> [tactics](#input\_tactics) | (Optional) The tactics of the alert rule. Defaults to [InitialAccess]. | `list(string)` | <pre>[<br/>  "InitialAccess"<br/>]</pre> | no |
| <a name="input_techniques"></a> [techniques](#input\_techniques) | (Optional) The techniques of the alert rule. Defaults to null | `list(string)` | `null` | no |
| <a name="input_trigger_operator"></a> [trigger\_operator](#input\_trigger\_operator) | (Optional) The trigger operator of the alert rule. Defaults to GreaterThan. | `string` | `"GreaterThan"` | no |
| <a name="input_trigger_threshold"></a> [trigger\_threshold](#input\_trigger\_threshold) | (Optional) The trigger threshold of the alert rule. Defaults to 0. | `number` | `0` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | (Required) The workspace that the alert is going to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_rule_id"></a> [alert\_rule\_id](#output\_alert\_rule\_id) | The ID of the alert rule. |
