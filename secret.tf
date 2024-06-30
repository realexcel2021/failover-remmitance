resource "random_password" "master" {
  length  = 20
  special = false
}

resource "random_string" "this" {
  special = false
  length = 5
}

locals {
  endpoint = module.aurora_postgresql_v2_primary.cluster_instances["one"].endpoint
}


resource "aws_secretsmanager_secret" "db_pass" {
  name = "database-terraform_secret_qwq"
  recovery_window_in_days = 0

  replica {
    region = local.region2
  }

}

resource "aws_secretsmanager_secret" "arc-cluster" {
  name = "arc-cluster-terraform_2x"
  recovery_window_in_days = 0

  replica {
    region = local.region2
  }
}

resource "aws_secretsmanager_secret" "arc-control-1" {
  name = "arc-control1-terraform_2x"
  recovery_window_in_days = 0

  replica {
    region = local.region2
  }
}

resource "aws_secretsmanager_secret" "arc-control-2" {
  name = "arc-control2-terraform_2x"
  recovery_window_in_days = 0
  

  replica {
    region = local.region2
  }
}


resource "aws_secretsmanager_secret_version" "arc-cluster" {
  secret_id     = aws_secretsmanager_secret.arc-cluster.id
  secret_string = "${aws_route53recoverycontrolconfig_cluster.this.arn}"
}

resource "aws_secretsmanager_secret_version" "arc-control-1" {
  secret_id     = aws_secretsmanager_secret.arc-control-1.id
  secret_string = "${aws_route53recoverycontrolconfig_routing_control.this1.arn}"
}

resource "aws_secretsmanager_secret_version" "arc-control-2" {
  secret_id     = aws_secretsmanager_secret.arc-control-2.id
  secret_string = "${aws_route53recoverycontrolconfig_routing_control.this2.arn}"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.db_pass.id #remittance
  secret_string = <<EOF
    {
    "password": "${random_password.master.result}", 
    "dbname": "remittance", 
    "engine": "postgres", 
    "port": 5432, 
    "dbInstanceIdentifier": "dbcluster1-instance1", 
    "host": "${local.endpoint}", 
    "username": "remitadmin"
    }
  EOF
}


