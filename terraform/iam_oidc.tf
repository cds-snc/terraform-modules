locals {
  test_role_name = "terraform-modules-test"
}

module "test_role" {
  source            = "github.com/cds-snc/terraform-modules//gh_oidc_role?ref=v10.11.4"
  billing_tag_value = var.billing_code
  roles = [
    {
      name      = local.test_role_name
      repo_name = "terraform-modules"
      claim     = "pull_request"
    }
  ]
}

# Split across three managed policies to stay under the 6144-character limit per policy.
locals {
  test_role_policies = {
    read  = data.aws_iam_policy_document.test_role_read.json
    write = data.aws_iam_policy_document.test_role_write.json
    iam   = data.aws_iam_policy_document.test_role_iam.json
  }
}

resource "aws_iam_policy" "test_role" {
  for_each = local.test_role_policies

  name        = "${local.test_role_name}-${each.key}"
  description = "Least-privilege permissions for the terraform-modules CI tests (${each.key})"
  policy      = each.value
}

resource "aws_iam_role_policy_attachment" "test_role" {
  for_each = aws_iam_policy.test_role

  role       = local.test_role_name
  policy_arn = each.value.arn
  depends_on = [
    module.test_role
  ]
}

data "aws_iam_policy_document" "test_role_read" {
  statement {
    sid    = "ReadForPlan"
    effect = "Allow"
    actions = [
      "athena:Get*",
      "athena:List*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codebuild:BatchGet*",
      "codebuild:List*",
      "ec2:Describe*",
      "ecr:Describe*",
      "ecr:GetLifecyclePolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:List*",
      "ecs:Describe*",
      "ecs:List*",
      "events:Describe*",
      "events:List*",
      "firehose:Describe*",
      "firehose:List*",
      "glue:Get*",
      "guardduty:Get*",
      "guardduty:List*",
      "iam:Get*",
      "iam:List*",
      "kms:Describe*",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:List*",
      "lambda:Get*",
      "lambda:List*",
      "logs:Describe*",
      "logs:List*",
      "rds:Describe*",
      "rds:ListTagsForResource",
      "route53resolver:Get*",
      "route53resolver:List*",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "secretsmanager:Describe*",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:List*",
      "servicediscovery:Get*",
      "servicediscovery:List*",
      "sns:Get*",
      "sns:List*",
      "wafv2:Get*",
      "wafv2:List*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "test_role_write" {
  statement {
    sid    = "WriteTestResources"
    effect = "Allow"
    actions = [
      # ec2: VPC networking only, no instances, volumes or key pairs
      "ec2:AllocateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateFlowLogs",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateNetworkAcl",
      "ec2:CreateNetworkAclEntry",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteFlowLogs",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteNetworkAcl",
      "ec2:DeleteNetworkAclEntry",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySecurityGroupRules",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress",
      "ec2:ReplaceNetworkAclAssociation",
      "ec2:ReplaceNetworkAclEntry",
      "ec2:ReplaceRoute",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",

      "athena:CreateNamedQuery",
      "athena:CreateWorkGroup",
      "athena:DeleteNamedQuery",
      "athena:DeleteWorkGroup",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:TagResource",
      "athena:UntagResource",
      "athena:UpdateWorkGroup",
      "ecs:CreateCluster",
      "ecs:CreateService",
      "ecs:DeleteCluster",
      "ecs:DeleteService",
      "ecs:DeleteTaskDefinitions",
      "ecs:DeregisterTaskDefinition",
      "ecs:PutClusterCapacityProviders",
      "ecs:RegisterTaskDefinition",
      "ecs:TagResource",
      "ecs:UntagResource",
      "ecs:UpdateCluster",
      "ecs:UpdateService",
      "events:DeleteRule",
      "events:DisableRule",
      "events:EnableRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "events:TagResource",
      "events:UntagResource",
      "glue:CreateDatabase",
      "glue:DeleteDatabase",
      "glue:UpdateDatabase",
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:PublishVersion",
      "lambda:PutFunctionConcurrency",
      "lambda:RemovePermission",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteQueryDefinition",
      "logs:DeleteResourcePolicy",
      "logs:DeleteRetentionPolicy",
      "logs:PutQueryDefinition",
      "logs:PutResourcePolicy",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource",
      "rds:AddTagsToResource",
      "rds:CreateDBClusterParameterGroup",
      "rds:DeleteDBClusterParameterGroup",
      "rds:ModifyDBClusterParameterGroup",
      "rds:RemoveTagsFromResource",
      "route53resolver:AssociateFirewallRuleGroup",
      "route53resolver:AssociateResolverQueryLogConfig",
      "route53resolver:CreateFirewallDomainList",
      "route53resolver:CreateFirewallRule",
      "route53resolver:CreateFirewallRuleGroup",
      "route53resolver:CreateResolverQueryLogConfig",
      "route53resolver:DeleteFirewallDomainList",
      "route53resolver:DeleteFirewallRule",
      "route53resolver:DeleteFirewallRuleGroup",
      "route53resolver:DeleteResolverQueryLogConfig",
      "route53resolver:DisassociateFirewallRuleGroup",
      "route53resolver:DisassociateResolverQueryLogConfig",
      "route53resolver:TagResource",
      "route53resolver:UntagResource",
      "route53resolver:UpdateFirewallDomains",
      "route53resolver:UpdateFirewallRule",
      "s3:AbortMultipartUpload",
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:PutAccelerateConfiguration",
      "s3:PutBucket*",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutObject",
      "s3:PutReplicationConfiguration",
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  statement {
    sid    = "ManageContainerImageParameter"
    effect = "Allow"
    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeleteParameter",
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:ListTagsForResource",
      "ssm:PutParameter",
      "ssm:RemoveTagsFromResource",
    ]
    resources = ["arn:aws:ssm:${var.region}:${var.account_id}:parameter/ecs/*"]
  }
}

data "aws_iam_policy_document" "test_role_iam" {
  statement {
    sid    = "ManageTestIamRolesAndPolicies"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:TagPolicy",
      "iam:TagRole",
      "iam:UntagPolicy",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRoleDescription",
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:role/*",
      "arn:aws:iam::${var.account_id}:policy/*",
    ]
  }

  statement {
    sid       = "PassRoleToTestedServices"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${var.account_id}:role/*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com", "lambda.amazonaws.com"]
    }
  }

  statement {
    sid       = "CreateEcsServiceLinkedRole"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::${var.account_id}:role/aws-service-role/ecs.amazonaws.com/*"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["ecs.amazonaws.com"]
    }
  }

  statement {
    sid    = "DenyChangesToCiRoles"
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = ["arn:aws:iam::${var.account_id}:role/terraform-modules-*"]
  }

  statement {
    sid       = "DenyPrivilegedManagedPolicies"
    effect    = "Deny"
    actions   = ["iam:AttachRolePolicy"]
    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"
      values = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
        "arn:aws:iam::aws:policy/IAMFullAccess",
        "arn:aws:iam::aws:policy/PowerUserAccess",
      ]
    }
  }

  statement {
    sid       = "DenyAssumingOtherRoles"
    effect    = "Deny"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }

  statement {
    sid     = "DenyTerraformStateBucket"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::cds-snc-terraform-modules-tfstate",
      "arn:aws:s3:::cds-snc-terraform-modules-tfstate/*",
    ]
  }
}
