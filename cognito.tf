resource "aws_cognito_user_pool" "user_pool" {
  name = "${local.name}"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_symbols = false 
    require_uppercase = true
    temporary_password_validity_days = 1
  }

  mfa_configuration = "OFF"



  # schema {
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true
  #   name                     = "email"
  #   required                 = true

  #   string_attribute_constraints {
  #     min_length = 1
  #     max_length = 256
  #   }
  # }

  
}

resource "aws_cognito_user" "this" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = "admin@${local.api_domain}"
  password     = "pA55word!" 

  attributes = {    
    email = "admin@${local.api_domain}"
  }
}

resource "aws_cognito_user_pool_client" "this1" {
  name = "ServerClient"
  generate_secret = true
  refresh_token_validity = 30
  allowed_oauth_flows = [ "code", "implicit" ]
  explicit_auth_flows = [ "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH" ]
  callback_urls = [ "https://${aws_cloudfront_distribution.this.domain_name}" ]
  allowed_oauth_scopes = [ "email", "openid", "profile" ]

  allowed_oauth_flows_user_pool_client = true
  prevent_user_existence_errors = "ENABLED"
  supported_identity_providers = [ "COGNITO" ]

  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_pool_client" "this2" {
  name = "ClientApp"
  generate_secret = false
  refresh_token_validity = 30
  allowed_oauth_flows = [ "code", "implicit" ]
  explicit_auth_flows = [ "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH" ]
  callback_urls = [ "https://${aws_cloudfront_distribution.this.domain_name}" ]
  allowed_oauth_scopes = [ "email", "openid", "profile" ]

  allowed_oauth_flows_user_pool_client = true
  prevent_user_existence_errors = "ENABLED"
  supported_identity_providers = [ "COGNITO" ]

  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "crf-remittance-terraform"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}


resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "remittance-terraform"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.this2.id
    provider_name           = "cognito-idp.${local.region1}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}" #
    server_side_token_check = false
  }

}


resource "aws_iam_role" "CognitoAuthorizedRole" {
  name               = "CognitoAuthorizedRole"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Effect": "Allow",
        "Condition" : {
          "StringEquals" : {
              "cognito-identity.amazonaws.com:aud" : "${aws_cognito_identity_pool.main.id}"     
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "authenticated"
        }
        }
      }
    ]
}

POLICY
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.CognitoAuthorizedRole.name
  policy_arn = module.CognitoAuthorizedPolicy.arn
}


module "CognitoAuthorizedPolicy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.0"

  name        = "CognitoAuthorizedPolicy"
  description = "Allow cognito to apigateway"

  policy = data.aws_iam_policy_document.CognitoAuthorizedPolicy.json
}

data "aws_iam_policy_document" "CognitoAuthorizedPolicy" {
  statement {
    sid       = "AllowCognito"
    actions   = ["cognito-sync:*", "cognito-identity:*", "execute-api:Invoke"]
    resources = ["*"]
  }
}


resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = "${aws_cognito_identity_pool.main.id}"

  roles = {
    "authenticated" = "${aws_iam_role.CognitoAuthorizedRole.arn}"
  }
}