resource "aws_api_gateway_rest_api" "my_api_sec" {
  name = "remittance-rest-api"
  description = "rest api"
  provider = aws.region2

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id

  provider = aws.region2

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.my_api_sec.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ 
        aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_sec_options,
        aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_sec,
        aws_api_gateway_integration.ApiGatewayMethodCreateRemittanceTable_sec,
        aws_api_gateway_integration.ApiGatewayMethodCreateRemittanceTable_sec_options,

        aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_sec_options,
        aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_sec,
        aws_api_gateway_integration.ApiGatewayMethodDropRemittanceTable_sec,
        aws_api_gateway_integration.ApiGatewayMethodDropRemittanceTable_sec_options,

        aws_api_gateway_method.ApiGatewayMethodGetRemittances_sec,
        aws_api_gateway_method.ApiGatewayMethodGetRemittances_sec_options,
        aws_api_gateway_integration.ApiGatewayMethodGetRemittances_sec_options,
        aws_api_gateway_integration.ApiGatewayMethodGetRemittances_sec,


        aws_api_gateway_method.ResourceCreateRemittance_sec,
        aws_api_gateway_method.ResourceCreateRemittance_sec_options,


        aws_api_gateway_method.ResourceUpdateRemittance_sec,
        aws_api_gateway_method.ResourceUpdateRemittance_sec_options,

        aws_api_gateway_method.ResourceDeleteRemittance_sec,
        aws_api_gateway_method.ResourceDeleteRemittance_sec_options,

        aws_api_gateway_method.ResourceClearRemittances_sec,
        aws_api_gateway_method.ResourceClearRemittances_sec_options,

        aws_api_gateway_method.ResourceExecuteRunbook_sec,
        aws_api_gateway_method.ResourceExecuteRunbook_sec_options,
        aws_api_gateway_integration.ResourceExecuteRunbook_sec

    ]
}

resource "aws_api_gateway_stage" "this_sec" {
  deployment_id = aws_api_gateway_deployment.this_sec.id
  rest_api_id   = aws_api_gateway_rest_api.my_api_sec.id
  stage_name    = "dev"
  provider = aws.region2
}

resource "aws_api_gateway_domain_name" "this_sec" {
  regional_certificate_arn = module.acm_api_sec.acm_certificate_arn
  domain_name     = "${local.api_domain}"
  provider = aws.region2
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
}


resource "aws_api_gateway_base_path_mapping" "this_sec" {
  api_id      = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  domain_name = aws_api_gateway_domain_name.this_sec.domain_name
  provider = aws.region2

  depends_on = [ aws_api_gateway_deployment.this_sec ]
}

resource "aws_api_gateway_authorizer" "demo_sec" {
  name                   = "CognitoAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.my_api_sec.id
  identity_source        = "method.request.header.authorization"
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [ "${aws_cognito_user_pool.user_pool.arn}" ]  
  provider = aws.region2
}

############################################
# create remittance 
############################################

resource "aws_api_gateway_resource" "ApiGatewayMethodCreateRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "create-remittance-table"
}

resource "aws_api_gateway_method" "ApiGatewayMethodCreateRemittanceTable_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ApiGatewayMethodCreateRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable_sec.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "this_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ApiGatewayMethodCreateRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.CreateRemittanceTableLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ApiGatewayMethodCreateRemittanceTable_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_sec_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  provider = aws.region2

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ApiGatewayMethodCreateRemittanceTable_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ApiGatewayMethodCreateRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ApiGatewayMethodCreateRemittanceTable_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_sec,
    aws_api_gateway_integration.ApiGatewayMethodCreateRemittanceTable_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}



############################################
# Drop remittance 
############################################

resource "aws_api_gateway_resource" "ApiGatewayMethodDropRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "drop-remittance-table"
}

resource "aws_api_gateway_method" "ApiGatewayMethodDropRemittanceTable_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ApiGatewayMethodDropRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable_sec.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "ApiGatewayMethodDropRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ApiGatewayMethodDropRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.DropRemittanceTableLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ApiGatewayMethodDropRemittanceTable_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_sec_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  provider = aws.region2

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ApiGatewayMethodDropRemittanceTable_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ApiGatewayMethodDropRemittanceTable_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ApiGatewayMethodDropRemittanceTable_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_sec,
    aws_api_gateway_integration.ApiGatewayMethodDropRemittanceTable_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}



############################################
# Get remittance 
############################################

resource "aws_api_gateway_resource" "ApiGatewayMethodGetRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "get-remittances"
}

resource "aws_api_gateway_method" "ApiGatewayMethodGetRemittances_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ApiGatewayMethodGetRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances_sec.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "ApiGatewayMethodGetRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ApiGatewayMethodGetRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.GetRemittancesLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ApiGatewayMethodGetRemittances_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances_sec_options.http_method
  type = "MOCK"
  provider = aws.region2
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ApiGatewayMethodGetRemittances_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ApiGatewayMethodGetRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances_sec.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ApiGatewayMethodGetRemittances_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ApiGatewayMethodGetRemittances_sec,
    aws_api_gateway_integration.ApiGatewayMethodGetRemittances_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}



############################################
# Create remittance 
############################################

resource "aws_api_gateway_resource" "ResourceCreateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "create-remittance"
}

resource "aws_api_gateway_method" "ResourceCreateRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ResourceCreateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance_sec.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "ResourceCreateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceCreateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.CreateRemittanceLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ResourceCreateRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance_sec_options.http_method
  provider = aws.region2
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ResourceCreateRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceCreateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ResourceCreateRemittance_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceCreateRemittance_sec,
    aws_api_gateway_integration.ResourceCreateRemittance_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}




############################################
# Update remittance 
############################################

resource "aws_api_gateway_resource" "ResourceUpdateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "update-remittance"
}

resource "aws_api_gateway_method" "ResourceUpdateRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ResourceUpdateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance_sec.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "ResourceUpdateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceUpdateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.UpdateRemittanceLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ResourceUpdateRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance_sec_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  provider = aws.region2

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ResourceUpdateRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceUpdateRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ResourceUpdateRemittance_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceUpdateRemittance_sec,
    aws_api_gateway_integration.ResourceUpdateRemittance_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}



############################################
# Delete remittance 
############################################

resource "aws_api_gateway_resource" "ResourceDeleteRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "delete-remittance"
}

resource "aws_api_gateway_method" "ResourceDeleteRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ResourceDeleteRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance_sec.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "ResourceDeleteRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceDeleteRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.DeleteRemittanceLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ResourceDeleteRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance_sec_options.http_method
  provider = aws.region2
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ResourceDeleteRemittance_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceDeleteRemittance_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance_sec.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ResourceDeleteRemittance_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceDeleteRemittance_sec,
    aws_api_gateway_integration.ResourceDeleteRemittance_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}


############################################
# Clear remittance 
############################################

resource "aws_api_gateway_resource" "ResourceClearRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "clear-remittances"
}

resource "aws_api_gateway_method" "ResourceClearRemittances_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ResourceClearRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances_sec.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "ResourceClearRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceClearRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances_sec.id
  http_method = aws_api_gateway_method.ResourceClearRemittances_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.ClearRemittancesLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ResourceClearRemittances_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances_sec.id
  http_method = aws_api_gateway_method.ResourceClearRemittances_sec_options.http_method
  provider = aws.region2
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ResourceClearRemittances_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances_sec.id
  http_method = aws_api_gateway_method.ResourceClearRemittances_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceClearRemittances_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances_sec.id
  http_method = aws_api_gateway_method.ResourceClearRemittances_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ResourceClearRemittances_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceClearRemittances_sec,
    aws_api_gateway_integration.ResourceClearRemittances_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}



############################################
# Execute Runbook 
############################################

resource "aws_api_gateway_resource" "ResourceExecuteRunbook_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  parent_id = aws_api_gateway_rest_api.my_api_sec.root_resource_id
  provider = aws.region2
  path_part = "execute-runbook"
}

resource "aws_api_gateway_method" "ResourceExecuteRunbook_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook_sec.id
  http_method = "OPTIONS"
  authorization = "NONE"
  provider = aws.region2
}

resource "aws_api_gateway_method" "ResourceExecuteRunbook_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook_sec.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  provider = aws.region2
  authorizer_id = aws_api_gateway_authorizer.demo_sec.id
}

resource "aws_api_gateway_method_settings" "ResourceExecuteRunbook_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  stage_name  = aws_api_gateway_stage.this_sec.stage_name
  method_path = "*/*"
  provider = aws.region2

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceExecuteRunbook_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook_sec.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook_sec.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.ExecuteRunbookLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
  provider = aws.region2
}

resource "aws_api_gateway_integration" "ResourceExecuteRunbook_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook_sec.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook_sec_options.http_method
  provider = aws.region2
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "'{\"statusCode\": 200}'"
  }
}

resource "aws_api_gateway_method_response" "ResourceExecuteRunbook_sec_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook_sec.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook_sec_options.http_method
  status_code = "200"
  provider = aws.region2


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceExecuteRunbook_sec" {
  rest_api_id = aws_api_gateway_rest_api.my_api_sec.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook_sec.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook_sec_options.http_method
  provider = aws.region2
  status_code = aws_api_gateway_method_response.ResourceExecuteRunbook_sec_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceExecuteRunbook_sec,
    aws_api_gateway_integration.ResourceExecuteRunbook_sec_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = "''"
  }
}
