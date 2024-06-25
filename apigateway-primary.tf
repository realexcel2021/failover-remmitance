resource "aws_api_gateway_rest_api" "my_api" {
  name = "remittance-rest-api"
  description = "rest api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.my_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ 
        aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_options,
        aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable,
        aws_api_gateway_integration.ApiGatewayMethodCreateRemittanceTable,
        aws_api_gateway_integration.ApiGatewayMethodCreateRemittanceTable_options,

        aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_options,
        aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable,
        aws_api_gateway_integration.ApiGatewayMethodDropRemittanceTable,
        aws_api_gateway_integration.ApiGatewayMethodDropRemittanceTable_options,

        aws_api_gateway_method.ApiGatewayMethodGetRemittances,
        aws_api_gateway_method.ApiGatewayMethodGetRemittances_options,
        aws_api_gateway_integration.ApiGatewayMethodGetRemittances_options,
        aws_api_gateway_integration.ApiGatewayMethodGetRemittances,


        aws_api_gateway_method.ResourceCreateRemittance,
        aws_api_gateway_method.ResourceCreateRemittance_options,


        aws_api_gateway_method.ResourceUpdateRemittance,
        aws_api_gateway_method.ResourceUpdateRemittance_options,

        aws_api_gateway_method.ResourceDeleteRemittance,
        aws_api_gateway_method.ResourceDeleteRemittance_options,

        aws_api_gateway_method.ResourceClearRemittances,
        aws_api_gateway_method.ResourceClearRemittances_options,

        aws_api_gateway_method.ResourceExecuteRunbook,
        aws_api_gateway_method.ResourceExecuteRunbook_options,
        aws_api_gateway_integration.ResourceExecuteRunbook

    ]
}


resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "dev"
}


resource "aws_api_gateway_authorizer" "demo" {
  name                   = "CognitoAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.my_api.id
  identity_source        = "method.request.header.authorization"
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [ "${aws_cognito_user_pool.user_pool.arn}" ]  
}

resource "aws_api_gateway_domain_name" "this" {
  regional_certificate_arn = module.acm_api.acm_certificate_arn
  domain_name     = "${local.api_domain}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
}


resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this.domain_name

  depends_on = [ aws_api_gateway_deployment.this ]
}

############################################
# create remittance 
############################################

resource "aws_api_gateway_resource" "ApiGatewayMethodCreateRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "create-remittance-table"
}

resource "aws_api_gateway_method" "ApiGatewayMethodCreateRemittanceTable_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ApiGatewayMethodCreateRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ApiGatewayMethodCreateRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.CreateRemittanceTableLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ApiGatewayMethodCreateRemittanceTable_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ApiGatewayMethodCreateRemittanceTable_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_options.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method_response" "ApiGatewayMethodCreateRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "get-cluster-info" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable_options.http_method
  status_code = aws_api_gateway_method_response.ApiGatewayMethodCreateRemittanceTable_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable,
    aws_api_gateway_integration.ApiGatewayMethodCreateRemittanceTable_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}

resource "aws_api_gateway_integration_response" "get-cluster-info_get" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodCreateRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable.http_method
  status_code = aws_api_gateway_method_response.ApiGatewayMethodCreateRemittanceTable.status_code
  

  depends_on = [
    aws_api_gateway_method.ApiGatewayMethodCreateRemittanceTable,
    aws_api_gateway_integration.ApiGatewayMethodCreateRemittanceTable
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
  }

  response_templates = {
    "application/json" = null
  }
}



############################################
# Drop remittance 
############################################

resource "aws_api_gateway_resource" "ApiGatewayMethodDropRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "drop-remittance-table"
}

resource "aws_api_gateway_method" "ApiGatewayMethodDropRemittanceTable_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ApiGatewayMethodDropRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "ApiGatewayMethodDropRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ApiGatewayMethodDropRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.DropRemittanceTableLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ApiGatewayMethodDropRemittanceTable_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ApiGatewayMethodDropRemittanceTable_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_options.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ApiGatewayMethodDropRemittanceTable" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodDropRemittanceTable.id
  http_method = aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable_options.http_method
  status_code = aws_api_gateway_method_response.ApiGatewayMethodDropRemittanceTable_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ApiGatewayMethodDropRemittanceTable,
    aws_api_gateway_integration.ApiGatewayMethodDropRemittanceTable_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}


############################################
# Get remittance 
############################################

resource "aws_api_gateway_resource" "ApiGatewayMethodGetRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "get-remittances"
}

resource "aws_api_gateway_method" "ApiGatewayMethodGetRemittances_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances.id
  http_method = "OPTIONS"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "ApiGatewayMethodGetRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "ApiGatewayMethodGetRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ApiGatewayMethodGetRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.GetRemittancesLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ApiGatewayMethodGetRemittances_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ApiGatewayMethodGetRemittances_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances_options.http_method
  status_code = "200"
  

  response_models = {
    "application/json" = "Empty"
  }


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false,
  }
}

resource "aws_api_gateway_integration_response" "ApiGatewayMethodGetRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ApiGatewayMethodGetRemittances.id
  http_method = aws_api_gateway_method.ApiGatewayMethodGetRemittances_options.http_method
  status_code = aws_api_gateway_method_response.ApiGatewayMethodGetRemittances_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ApiGatewayMethodGetRemittances,
    aws_api_gateway_integration.ApiGatewayMethodGetRemittances_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}





############################################
# Create remittance 
############################################

resource "aws_api_gateway_resource" "ResourceCreateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "create-remittance"
}

resource "aws_api_gateway_method" "ResourceCreateRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ResourceCreateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "ResourceCreateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceCreateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.CreateRemittanceLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ResourceCreateRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ResourceCreateRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance_options.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceCreateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceCreateRemittance.id
  http_method = aws_api_gateway_method.ResourceCreateRemittance_options.http_method
  status_code = aws_api_gateway_method_response.ResourceCreateRemittance_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceCreateRemittance,
    aws_api_gateway_integration.ResourceCreateRemittance_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}




############################################
# Update remittance 
############################################

resource "aws_api_gateway_resource" "ResourceUpdateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "update-remittance"
}

resource "aws_api_gateway_method" "ResourceUpdateRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ResourceUpdateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "ResourceUpdateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceUpdateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.UpdateRemittanceLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ResourceUpdateRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ResourceUpdateRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance_options.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceUpdateRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceUpdateRemittance.id
  http_method = aws_api_gateway_method.ResourceUpdateRemittance_options.http_method
  status_code = aws_api_gateway_method_response.ResourceUpdateRemittance_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceUpdateRemittance,
    aws_api_gateway_integration.ResourceUpdateRemittance_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}



############################################
# Delete remittance 
############################################

resource "aws_api_gateway_resource" "ResourceDeleteRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "delete-remittance"
}

resource "aws_api_gateway_method" "ResourceDeleteRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ResourceDeleteRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "ResourceDeleteRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceDeleteRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.DeleteRemittanceLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ResourceDeleteRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ResourceDeleteRemittance_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance_options.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceDeleteRemittance" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceDeleteRemittance.id
  http_method = aws_api_gateway_method.ResourceDeleteRemittance_options.http_method
  status_code = aws_api_gateway_method_response.ResourceDeleteRemittance_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceDeleteRemittance,
    aws_api_gateway_integration.ResourceDeleteRemittance_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}


############################################
# Clear remittance 
############################################

resource "aws_api_gateway_resource" "ResourceClearRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "clear-remittances"
}

resource "aws_api_gateway_method" "ResourceClearRemittances_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ResourceClearRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "ResourceClearRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceClearRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances.id
  http_method = aws_api_gateway_method.ResourceClearRemittances.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.ClearRemittancesLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ResourceClearRemittances_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances.id
  http_method = aws_api_gateway_method.ResourceClearRemittances_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ResourceClearRemittances_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances.id
  http_method = aws_api_gateway_method.ResourceClearRemittances_options.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceClearRemittances" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceClearRemittances.id
  http_method = aws_api_gateway_method.ResourceClearRemittances_options.http_method
  status_code = aws_api_gateway_method_response.ResourceClearRemittances_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceClearRemittances,
    aws_api_gateway_integration.ResourceClearRemittances_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}



############################################
# Execute Runbook 
############################################

resource "aws_api_gateway_resource" "ResourceExecuteRunbook" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "execute-runbook"
}

resource "aws_api_gateway_method" "ResourceExecuteRunbook_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "ResourceExecuteRunbook" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
}

resource "aws_api_gateway_method_settings" "ResourceExecuteRunbook" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_integration" "ResourceExecuteRunbook" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${module.ExecuteRunbookLambdaFunction.lambda_function_qualified_invoke_arn}"  
  credentials = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
}

resource "aws_api_gateway_integration" "ResourceExecuteRunbook_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook_options.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = jsonencode({statusCode = 200})
  }
}

resource "aws_api_gateway_method_response" "ResourceExecuteRunbook_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook_options.http_method
  status_code = "200"


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "ResourceExecuteRunbook" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.ResourceExecuteRunbook.id
  http_method = aws_api_gateway_method.ResourceExecuteRunbook_options.http_method
  status_code = aws_api_gateway_method_response.ResourceExecuteRunbook_options.status_code
  

  depends_on = [
    aws_api_gateway_method.ResourceExecuteRunbook,
    aws_api_gateway_integration.ResourceExecuteRunbook_options
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = null
  }
}
