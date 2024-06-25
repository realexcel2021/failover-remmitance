output "cognito_user_pool_id"{
    value = aws_cognito_user_pool.user_pool.id
}

output "cognito_identity_pool_id"{
    value = aws_cognito_identity_pool.main.id
}


output "cognito_web_client_id"{
    value = aws_cognito_user_pool_client.this2.id
}


output "cognito_domain_place_holder"{
    value = "${aws_cognito_user_pool.user_pool.domain}.auth.us-east-1.amazoncognito.com"
}

output "domain_name" {
  value = local.api_domain
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.this.domain_name
}