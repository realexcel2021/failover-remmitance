resource "aws_lambda_layer_version" "lambda_layer_sec" {
  filename   = "src/python-layer.zip"
  layer_name = "remmitance-layer"

  provider = aws.region2

  compatible_runtimes = ["python3.11", "python3.9", "python3.10", "python3.8"]
}

module "CreateRemittanceTableLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-CreateRemittanceTable"
  handler       = "api.create_remittance_table"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}


module "DropRemittanceTableLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-DropRemittanceTable"
  handler       = "api.drop_remittance_table"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}


module "GetRemittancesLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-GetRemittances"
  handler       = "api.get_remittances"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}


module "CreateRemittanceLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-CreateRemittance"
  handler       = "api.create_remittance"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}


module "UpdateRemittanceLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-UpdateRemittance"
  handler       = "api.update_remittance"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}

module "DeleteRemittanceLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-DeleteRemittance"
  handler       = "api.delete_remittance"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}


module "ClearRemittancesLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-ClearRemittances"
  handler       = "api.clear_remittances"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}


module "ExecuteRunbookLambdaFunction_sec" {
  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.region2
  }
  layers = [ aws_lambda_layer_version.lambda_layer_sec.arn, "arn:aws:lambda:${local.region2}:580247275435:layer:LambdaInsightsExtension:21" ]


  function_name = "tf-sec-ExecuteRunbook"
  handler       = "api.execute_runbook"
  runtime       = "python3.8"
  architectures = ["x86_64"]
  timeout       = 900
  tracing_mode  = "Active"
  publish       = true
  store_on_s3   = false
  memory_size   = 1024

  local_existing_package = "${path.module}/src/database/src/database.zip"
  create_package         = false

  vpc_subnet_ids = module.vpc_secondary.private_subnets
  vpc_security_group_ids = [module.LambdaSecurityGroup_secondary.security_group_id]

   attach_policies    = true
   policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
   number_of_policies = 2

   attach_policy_statements = true
   policy_statements = {
     ec2 = {
       effect    = "Allow",
       actions   = [
        "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", 
        "ec2:AttachNetworkInterface"
        ],
       resources = ["*"]
     }

     secrets_manager = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = ["*"]
     }
     xray = {
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      resources = ["*"]
     }
    ssm = {
      effect = "Allow"
      actions = [
        "ssm:StartAutomationExecution"
      ]
      resources = ["*"]
    }
   }
}