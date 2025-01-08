module "simple" {
  source       = "github.com/cds-snc/terraform-modules//sentinel_nrt_alert_rule"
  description  = "NRT Login to AWS Management Console without MFA"
  display_name = "NRT Login to AWS Management Console without MFA"
  workspace_id = data.azurerm_log_analytics_workspace.workspace.id
  query        = <<-EOT
AWSCloudTrail
| where EventName =~ "ConsoleLogin"
| extend MFAUsed = tostring(parse_json(AdditionalEventData).MFAUsed), LoginResult = tostring(parse_json(ResponseElements).ConsoleLogin), indexId = indexof(tostring(UserIdentityPrincipalid),":")
| where MFAUsed !~ "Yes" and LoginResult !~ "Failure"
| where SessionIssuerUserName !contains "AWSReservedSSO"
| summarize StartTimeUtc = min(TimeGenerated), EndTimeUtc = max(TimeGenerated) by EventName, EventTypeName, LoginResult, MFAUsed, UserIdentityAccountId,  UserIdentityPrincipalid, UserAgent,
UserIdentityUserName, SessionMfaAuthenticated, SourceIpAddress, AWSRegion, indexId
| extend timestamp = StartTimeUtc, AccountCustomEntity = iif(isempty(UserIdentityUserName),substring(UserIdentityPrincipalid, toint(indexId)+1), UserIdentityUserName), IPCustomEntity = SourceIpAddress
EOT
}

