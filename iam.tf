module "apigateway_put_events_to_lambda_us_east_1" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.0"

  create_role = true

  role_name         = "apigateway-put-events-to-lambda_us-east_1"
  role_requires_mfa = false

  trusted_role_services = ["apigateway.amazonaws.com"]

  custom_role_policy_arns = [
    module.apigateway_put_events_to_lambda_policy.arn
  ]
}

module "AutomationServiceRole" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.0"

  create_role = true

  role_name         = "AutomationServiceRole-tf"
  role_requires_mfa = false

  trusted_role_services = ["ssm.amazonaws.com", "ec2.amazonaws.com"]

  custom_role_policy_arns = [
    module.passrole.arn, 
    "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
  ]
}

module "apigateway_put_events_to_lambda_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.0"

  name        = "apigateway-put-events-to-lambda-global"
  description = "Allow PutEvents to Lamda"

  policy = data.aws_iam_policy_document.apigateway_put_events_to_lambda_policy_doc.json
}

module "passrole" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.0"

  name        = "passrole-tf"
  description = "Allow Runbook"

  policy = data.aws_iam_policy_document.runbook.json
}


data "aws_iam_policy_document" "apigateway_put_events_to_lambda_policy_doc" {
  statement {
    sid       = "AllowInvokeFunction"
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "runbook" {
  statement {
    sid       = "IamPassRole"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowRds"
    actions   = ["rds:*"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowSecrets"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowArc"
    actions   = ["route53-recovery-control-config:*"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowArcCluster"
    actions   = ["route53-recovery-cluster:*"]
    resources = ["*"]
  }

}