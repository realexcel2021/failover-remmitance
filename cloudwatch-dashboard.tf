resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Application"

  dashboard_body = <<EOF


        {
          "widgets": [
              {
                  "height": 2,
                  "width": 13,
                  "y": 2,
                  "x": 0,
                  "type": "alarm",
                  "properties": {
                      "title": "Composite Alarms by Service",
                      "alarms": [
                          "arn:aws:cloudwatch:${local.region1}:${data.aws_caller_identity.current.account_id}:alarm:API_Gateway_Health",
                          "arn:aws:cloudwatch:${local.region1}:${data.aws_caller_identity.current.account_id}:alarm:Lambda_Health",
                          "arn:aws:cloudwatch:${local.region1}:${data.aws_caller_identity.current.account_id}:alarm:RDS_Health"
                      ]
                  }
              },
              {
                  "height": 3,
                  "width": 8,
                  "y": 1,
                  "x": 13,
                  "type": "log",
                  "properties": {
                      "query": "SOURCE '/aws/events/aws_health_api_gateway' | fields @timestamp, @message\n| sort @timestamp desc\n| limit 20",
                      "region": "${local.region1}",
                      "stacked": false,
                      "title": "AWS Health - API Gateway",
                      "view": "table"
                  }
              },
              {
                  "height": 1,
                  "width": 11,
                  "y": 0,
                  "x": 13,
                  "type": "text",
                  "properties": {
                      "markdown": "## AWS Health Event Logs"
                  }
              },
              {
                  "height": 3,
                  "width": 8,
                  "y": 4,
                  "x": 13,
                  "type": "log",
                  "properties": {
                      "query": "SOURCE '/aws/events/aws_health_lambda' | fields @timestamp, @message\n| sort @timestamp desc\n| limit 20",
                      "region": "${local.region1}",
                      "stacked": false,
                      "title": "AWS Health - Lambda",
                      "view": "table"
                  }
              },
              {
                  "height": 3,
                  "width": 8,
                  "y": 7,
                  "x": 13,
                  "type": "log",
                  "properties": {
                      "query": "SOURCE '/aws/events/aws_health_rds' | fields @timestamp, @message\n| sort @timestamp desc\n| limit 20",
                      "region": "${local.region1}",
                      "stacked": false,
                      "title": "AWS Health - RDS",
                      "view": "table"
                  }
              },
              {
                  "height": 4,
                  "width": 15,
                  "y": 26,
                  "x": 0,
                  "type": "metric",
                  "properties": {
                      "metrics": [
                          [ "AWS/RDS", "CPUUtilization", "DBClusterIdentifier", "dbcluster1" ],
                          [ ".", "Deadlocks", ".", "." ],
                          [ ".", "FreeableMemory", ".", "." ],
                          [ ".", "ReadLatency", ".", "." ],
                          [ ".", "WriteLatency", ".", "." ]
                      ],
                      "view": "singleValue",
                      "region": "${local.region1}",
                      "yAxis": {
                          "left": {
                              "min": 0,
                              "max": 100
                          }
                      },
                      "title": "dbcluster1-instance1",
                      "period": 300,
                      "setPeriodToTimeRange": true,
                      "sparkline": false,
                      "trend": false,
                      "stacked": false,
                      "stat": "Average",
                      "singleValueFullPrecision": false
                  }
              },
              {
                  "height": 1,
                  "width": 13,
                  "y": 4,
                  "x": 0,
                  "type": "text",
                  "properties": {
                      "markdown": "## Integration"
                  }
              },
              {
                  "height": 1,
                  "width": 19,
                  "y": 24,
                  "x": 0,
                  "type": "text",
                  "properties": {
                      "markdown": "## Storage\n"
                  }
              },
              {
                  "height": 1,
                  "width": 19,
                  "y": 10,
                  "x": 0,
                  "type": "text",
                  "properties": {
                      "markdown": "## Compute\n"
                  }
              },
              {
                  "height": 2,
                  "width": 13,
                  "y": 0,
                  "x": 0,
                  "type": "text",
                  "properties": {
                      "markdown": "# Application Health Dashboard\nCombined Dashboard of **AWS Health** and **health of each service** for the Regional Failover solution.\n \n"
                  }
              },
              {
                  "height": 4,
                  "width": 3,
                  "y": 1,
                  "x": 21,
                  "type": "metric",
                  "properties": {
                      "sparkline": false,
                      "view": "singleValue",
                      "metrics": [
                          [ "AWS/Events", "Invocations", "RuleName", "aws_health_api_gateway" ]
                      ],
                      "region": "${local.region1}",
                      "title": "API Gateway Health Events"
                  }
              },
              {
                  "height": 4,
                  "width": 12,
                  "y": 6,
                  "x": 0,
                  "type": "metric",
                  "properties": {
                      "metrics": [
                          [ "AWS/ApiGateway", "Count", "ApiName", "Remittance", { "yAxis": "left", "label": "API Calls" } ],
                          [ ".", "Latency", ".", ".", { "stat": "Average", "label": "Avg Latency" } ],
                          [ ".", "4XXError", ".", "." ],
                          [ ".", "5XXError", ".", "." ]
                      ],
                      "sparkline": false,
                      "view": "singleValue",
                      "region": "${local.region1}",
                      "period": 300,
                      "stat": "Sum",
                      "setPeriodToTimeRange": true,
                      "trend": false,
                      "liveData": false,
                      "stacked": false,
                      "singleValueFullPrecision": false,
                      "title": "Dev Resource APIs"
                  }
              },
              {
                  "height": 4,
                  "width": 11,
                  "y": 20,
                  "x": 0,
                  "type": "metric",
                  "properties": {
                      "metrics": [
                          [ "AWS/Lambda", "Invocations", "FunctionName", "UpdateRemittance" ],
                          [ ".", "Errors", ".", "." ],
                          [ ".", "Duration", ".", ".", { "stat": "Average" } ],
                          [ ".", "Throttles", ".", "." ]
                      ],
                      "sparkline": false,
                      "view": "singleValue",
                      "region": "${local.region1}",
                      "period": 300,
                      "stat": "Sum",
                      "setPeriodToTimeRange": true,
                      "trend": false,
                      "title": "UpdateRemittance"
                  }
              },
              {
                  "height": 4,
                  "width": 11,
                  "y": 12,
                  "x": 0,
                  "type": "metric",
                  "properties": {
                      "metrics": [
                          [ "AWS/Lambda", "Invocations", "FunctionName", "GetRemittances", { "region": "${local.region1}" } ],
                          [ "AWS/Lambda", "Errors", "FunctionName", "GetRemittances", { "region": "${local.region1}" } ],
                          [ "AWS/Lambda", "Duration", "FunctionName", "GetRemittances", { "stat": "Average", "region": "${local.region1}" } ],
                          [ "AWS/Lambda", "Throttles", "FunctionName", "GetRemittances", { "region": "${local.region1}" } ]
                      ],
                      "sparkline": false,
                      "view": "singleValue",
                      "region": "${local.region1}",
                      "stat": "Sum",
                      "period": 300,
                      "setPeriodToTimeRange": true,
                      "trend": false,
                      "title": "GetRemittance",
                      "stacked": false
                  }
              },
              {
                  "height": 4,
                  "width": 11,
                  "y": 16,
                  "x": 0,
                  "type": "metric",
                  "properties": {
                      "metrics": [
                          [ "AWS/Lambda", "Invocations", "FunctionName", "CreateRemittance" ],
                          [ ".", "Errors", ".", "." ],
                          [ ".", "Duration", ".", ".", { "stat": "Average" } ],
                          [ ".", "Throttles", ".", "." ]
                      ],
                      "sparkline": false,
                      "view": "singleValue",
                      "region": "${local.region1}",
                      "period": 300,
                      "stat": "Sum",
                      "setPeriodToTimeRange": true,
                      "trend": false,
                      "title": "CreateRemittance"
                  }
              },
              {
                  "height": 10,
                  "width": 24,
                  "y": 30,
                  "x": 0,
                  "type": "trace",
                  "properties": {
                      "service": "ServiceLensWidget",
                      "title": "Region Failover Solution Traces",
                      "params": {
                          "view": "tracesTable",
                          "group": "Default",
                          "region": "${local.region1}"
                      }
                  }
              },
              {
                  "height": 1,
                  "width": 12,
                  "y": 5,
                  "x": 0,
                  "type": "text",
                  "properties": {
                      "markdown": "### API Gateway"
                  }
              },
              {
                  "height": 1,
                  "width": 18,
                  "y": 11,
                  "x": 0,
                  "type": "text",
                  "properties": {
                      "markdown": "### Lambda"
                  }
              },
              {
                  "height": 1,
                  "width": 15,
                  "y": 25,
                  "x": 0,
                  "type": "text",
                  "properties": {
                      "markdown": "### RDS Aurora PostgreSQL\n"
                  }
              },
              {
                  "height": 4,
                  "width": 7,
                  "y": 12,
                  "x": 11,
                  "type": "metric",
                  "properties": {
                      "metrics": [
                          [ "LambdaGetRemittance", "AccessDeniedException", { "color": "#d62728", "label": "SecretsManager AccessDeniedException" } ],
                          [ ".", "DBConnectionTimedOut" ]
                      ],
                      "sparkline": false,
                      "view": "singleValue",
                      "region": "${local.region1}",
                      "title": "GetRemittance - Function Errors",
                      "period": 300,
                      "stat": "Sum",
                      "setPeriodToTimeRange": true,
                      "trend": false
                  }
              }
          ]
        }


EOF
}