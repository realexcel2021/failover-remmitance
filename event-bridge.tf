resource "aws_cloudwatch_log_group" "LogGroupAWSHealthAPIGateway" {
  name = "/aws/events/aws_health_api_gateway"
  retention_in_days = 7


}

resource "aws_cloudwatch_log_group" "LogGroupAWSHealthLambda" {
  name = "/aws/events/aws_health_lambda"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "LogGroupAWSHealthRDS" {
  name = "/aws/events/aws_health_rds"
  retention_in_days = 7
}



resource "aws_cloudwatch_event_rule" "EventBridgeRuleAWSHealthAPIGateway" {
  name        = "aws_health_api_gateway"
  state       = "ENABLED" 

  event_pattern = <<EOF

          {
            "source": ["aws.health"],
            "detail-type": ["AWS Health Event"],
            "detail": {
              "service": ["APIGATEWAY"],
              "eventTypeCategory": ["issue"],
              "eventTypeCode": ["AWS_APIGATEWAY_API_ISSUE", "AWS_APIGATEWAY_OPERATIONAL_ISSUE"]
            }
          }

EOF

}

resource "aws_cloudwatch_event_target" "EventBridgeRuleAWSHealthAPIGateway" {
  rule      = aws_cloudwatch_event_rule.EventBridgeRuleAWSHealthAPIGateway.name
  target_id = "CloudWatchLogGroup_api_gateway"
  arn       = aws_cloudwatch_log_group.LogGroupAWSHealthAPIGateway.arn
}


resource "aws_cloudwatch_event_rule" "EventBridgeRuleAWSHealthLambda" {
  name        = "aws_health_lambda"
  state       = "ENABLED" 

  event_pattern = <<EOF

          {
            "source": ["aws.health"],
            "detail-type": ["AWS Health Event"],
            "detail": {
              "service": ["LAMBDA"],
              "eventTypeCategory": ["issue"],
              "eventTypeCode": ["AWS_LAMBDA_CONSOLE_ISSUE", "AWS_LAMBDA_IAM_ISSUE", "AWS_LAMBDA_API_ISSUE", "AWS_LAMBDA_OPERATIONAL_ISSUE"]
            }
          }

EOF

}

resource "aws_cloudwatch_event_target" "EventBridgeRuleAWSHealthLambda" {
  rule      = aws_cloudwatch_event_rule.EventBridgeRuleAWSHealthLambda.name
  target_id = "CloudWatchLogGroup_lambda"
  arn       = aws_cloudwatch_log_group.LogGroupAWSHealthLambda.arn
}


resource "aws_cloudwatch_event_rule" "EventBridgeRuleAWSHealthRDS" {
  name        = "aws_health_rds"
  state       = "ENABLED" 

  event_pattern = <<EOF

          {
            "source": ["aws.health"],
            "detail-type": ["AWS Health Event"],
            "detail": {
              "service": ["RDS"],
              "eventTypeCategory": ["issue"],
              "eventTypeCode": ["AWS_RDS_CONNECTIVITY_ISSUE", "AWS_RDS_OPERATIONAL_ISSUE", "AWS_RDS_API_ISSUE", "AWS_RDS_STORAGE_FAILURE_MAZ", "AWS_RDS_STORAGE_FAILURE_SAZ", "AWS_RDS_STORAGE_FAILURE_READREPLICA", "AWS_RDS_STORAGE_FAILURE_DB_CORRUPTION", "AWS_RDS_INCREASED_CREATE_SCALING_LATENCIES"]
            }
          }

EOF

}

resource "aws_cloudwatch_event_target" "EventBridgeRuleAWSHealthRDS" {
  rule      = aws_cloudwatch_event_rule.EventBridgeRuleAWSHealthRDS.name
  target_id = "CloudWatchLogGroup_rds"
  arn       = aws_cloudwatch_log_group.LogGroupAWSHealthRDS.arn
}