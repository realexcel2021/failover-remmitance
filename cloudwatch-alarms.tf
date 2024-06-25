resource "aws_cloudwatch_metric_alarm" "APIGateway4XXErrorAlarm" {
  alarm_name = "AWSAPIGateway-4xxErrors-tf"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
     ApiName = "remittance-rest-api"
  }


  threshold = 0
  treat_missing_data = "notBreaching"
  statistic         = "Average"
  metric_name       = "4XXError"
  namespace         = "AWS/ApiGateway" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "APIGateway5xxErrorAlarm" {
  alarm_name = "AWSAPIGateway-5xxErrors-tf"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
    ApiName = "remittance-rest-api"
  }
  

  threshold = 0
  treat_missing_data = "notBreaching"
  statistic         = "Average"
  metric_name       = "5XXError"
  namespace         = "AWS/ApiGateway" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

  depends_on = [ aws_api_gateway_rest_api.my_api ]

}

resource "aws_cloudwatch_metric_alarm" "APIGatewayLatencyAlarm" {
  alarm_name = "AWSAPIGateway-Latency-tf"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
    ApiName = "remittance-rest-api"
  }
  

  threshold = 1000
  treat_missing_data = "notBreaching"
  statistic         = "Average"
  namespace         = "AWS/ApiGateway" 
  metric_name       = "AWSAPIGateway-Latency"
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSLambdaGetRemittanceErrorsAlarm" {
  alarm_name = "AWSLamdba-GetRemittance-Errors-tf"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
    FunctionName = "tf-GetRemittances"
  }


  threshold = 0
  treat_missing_data = "notBreaching"
  statistic         = "Sum"
  metric_name       = "Errors"
  namespace         = "AWS/Lambda" 
  period            = 60
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSLambdaGetRemittanceInvocationsAlarm" {
  alarm_name = "AWSLambda-GetRemittance-Invocations"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
  FunctionName = "tf-GetRemittances"
  }
  

  threshold = 2
  treat_missing_data = "notBreaching"
  statistic         = "Average"
  metric_name       = "Errors"
  namespace         = "AWS/Lambda" 
  period            = 60
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSLambdaGetRemittanceDurationAlarm" {
  alarm_name = "AWSLambda-GetRemittance-Duration"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
FunctionName = "tf-GetRemittances"
  }
  

  threshold = 10000
  statistic         = "Average"
  metric_name       = "Duration"
  namespace         = "AWS/Lambda" 
  period            = 900
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []
  treat_missing_data = "notBreaching"

}


resource "aws_cloudwatch_metric_alarm" "AWSLambdaCreateRemittanceErrorsAlarm" {
  alarm_name = "AWSLambda-CreateRemittance-Errors"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
FunctionName = "tf-CreateRemittance"
  }


  threshold = 0
  treat_missing_data = "notBreaching"
  statistic         = "Sum"
  metric_name       = "Errors"
  namespace         = "AWS/Lambda" 
  period            = 60
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}


resource "aws_cloudwatch_metric_alarm" "AWSLambdaCreateRemittanceInvocationsAlarm" {
  alarm_name = "AWSLambda-CreateRemittance-Invocation"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
  FunctionName= "tf-CreateRemittance"
  }


  threshold = 2
  treat_missing_data = "notBreaching"
  statistic         = "Average"
  metric_name       = "Errors"
  namespace         = "AWS/Lambda" 
  period            = 60
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSLambdaCreateRemittanceDurationAlarm" {
  alarm_name = "AWSLambda-CreateRemittance-Duration"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
FunctionName = "tf-CreateRemittance"
  }
  

  threshold = 10000
  statistic         = "Average"
  namespace         = "AWS/Lambda" 
  metric_name       = "Duration"
  period            = 900
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []
  treat_missing_data = "notBreaching"
}


resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1CPUUtilizationAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-CPU-Utilization"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = false
  dimensions             = {
    DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 70
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "CPUUtilization"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighDBConnectionsAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-DB-Connections"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = false
  dimensions             = {
DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 100
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "DatabaseConnections"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighDeadlocksAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-Deadlocks"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 10
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "Deadlocks"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighNetworkReceiveThroughputAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-Network-Receive-Throughput"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 10485760
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "NetworkReceiveThroughput"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighNetworkTransmitThroughputAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-Network-Transmit-Throughput"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 10485760
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "NetworkTransmitThroughput"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighQueriesAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-Queries"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
    DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 100
  statistic         = "Average"
  metric_name       = "Queries"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighQueueDepthAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-Queue-Depth"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
 DBInstanceIdentifier = "${local.name}-primary-one"
  }


  threshold = 50
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "DiskQueueDepth"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighReadLatencyAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-Read-Latency"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 0.1
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "ReadLatency"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_metric_alarm" "AWSRDSdbcluster1instance1HighWriteLatencyAlarm" {
  alarm_name = "awsrds-dbcluster1-instance1-High-Write-Latency"
  comparison_operator    = "GreaterThanOrEqualToThreshold"
  evaluation_periods     = 1
  datapoints_to_alarm    = 1 
  actions_enabled        = true
  dimensions             = {
DBInstanceIdentifier = "${local.name}-primary-one"
  }
  

  threshold = 0.1
  treat_missing_data = "missing"
  statistic         = "Average"
  metric_name       = "WriteLatency"
  namespace         = "AWS/RDS" 
  period            = 300
  ok_actions        = []
  alarm_actions     = []
  insufficient_data_actions = []

}

resource "aws_cloudwatch_composite_alarm" "APIGatewayHealthCompositeAlarm" {
  alarm_name        = "API_Gateway_Health"

  alarm_actions = []
  actions_enabled = true
  insufficient_data_actions = []
  ok_actions = []

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.APIGateway4XXErrorAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.APIGateway5xxErrorAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.APIGatewayLatencyAlarm.alarm_name})"

depends_on = [ 
        aws_cloudwatch_metric_alarm.APIGateway4XXErrorAlarm,
        aws_cloudwatch_metric_alarm.APIGateway5xxErrorAlarm,
        aws_cloudwatch_metric_alarm.APIGatewayLatencyAlarm
 ]

}

resource "aws_cloudwatch_composite_alarm" "LambdaHealthCompositeAlarm" {
  alarm_name        = "Lambda_Health"

  alarm_actions = []
  actions_enabled = true
  insufficient_data_actions = []
  ok_actions = []

  alarm_rule ="ALARM(${aws_cloudwatch_metric_alarm.AWSLambdaGetRemittanceErrorsAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSLambdaGetRemittanceDurationAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSLambdaCreateRemittanceErrorsAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSLambdaCreateRemittanceDurationAlarm.alarm_name})"

depends_on = [ 
      aws_cloudwatch_metric_alarm.AWSLambdaGetRemittanceErrorsAlarm,
      aws_cloudwatch_metric_alarm.AWSLambdaGetRemittanceDurationAlarm,
      aws_cloudwatch_metric_alarm.AWSLambdaCreateRemittanceErrorsAlarm,
      aws_cloudwatch_metric_alarm.AWSLambdaCreateRemittanceDurationAlarm
 ]

}

resource "aws_cloudwatch_composite_alarm" "RDSHealthCompositeAlarm" {
  alarm_name        = "RDS_Health"

  alarm_actions = []
  actions_enabled = true
  insufficient_data_actions = []
  ok_actions = []

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1CPUUtilizationAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighDBConnectionsAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighDeadlocksAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighNetworkReceiveThroughputAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighNetworkTransmitThroughputAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighQueriesAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighQueueDepthAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighReadLatencyAlarm.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighWriteLatencyAlarm.alarm_name})"

depends_on = [ 
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1CPUUtilizationAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighDBConnectionsAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighDeadlocksAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighNetworkReceiveThroughputAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighNetworkTransmitThroughputAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighQueriesAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighQueueDepthAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighReadLatencyAlarm,
      aws_cloudwatch_metric_alarm.AWSRDSdbcluster1instance1HighWriteLatencyAlarm
 ]

}