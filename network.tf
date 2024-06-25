module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  single_nat_gateway = true
  enable_nat_gateway = true

  tags = local.tags
}

module "vpc_secondary" {
  source  = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = aws.region2
  }

  name = local.name
  cidr = local.vpc_cidr_secondary

  azs              = local.azs_secondary
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr_secondary, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr_secondary, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr_secondary, 8, k + 6)]
  single_nat_gateway = true
  enable_nat_gateway = true

  tags = local.tags
}


###################################
# vpc endpoints primary
###################################

module "vpc_endpoints_primary" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service             = "s3"
      private_dns_enabled = true
      dns_options = {
        private_dns_only_for_inbound_resolver_endpoint = false
      }
      tags = { Name = "s3-vpc-endpoint" }
    },
    rds = {
      service             = "rds"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },

    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
  }

  tags = local.tags
}



###################################
# vpc endpoints secondry
###################################

module "vpc_endpoints_secondary" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc_secondary.vpc_id

  providers = {
    aws = aws.region2
  }

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc_secondary.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service             = "s3"
      private_dns_enabled = true
      dns_options = {
        private_dns_only_for_inbound_resolver_endpoint = false
      }
      tags = { Name = "s3-vpc-endpoint" }
    },
    rds = {
      service             = "rds"
      private_dns_enabled = true
      subnet_ids          = module.vpc_secondary.private_subnets
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc_secondary.private_subnets
    },

    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc_secondary.private_subnets
    }
  }

  tags = local.tags
}


################################################
# security group primary region
################################################

module "LambdaSecurityGroup" {
  source = "terraform-aws-modules/security-group/aws"


  name        = "remittance-lambda-security-group"
  description = "Lambda Security Group"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.vpc_cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      protocol = "-1"
      from_port = 0
      to_port = 65535
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "remittance-lambda-security-group"
  }
}


module "AuroraSecurityGroup" {
  source = "terraform-aws-modules/security-group/aws"


  name        = "remittance-lambda-security-group"
  description = "Lambda Security Group"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = local.vpc_cidr
    },
  ]

  egress_with_cidr_blocks = [
    {
      protocol = "-1"
      from_port = 0
      to_port = 65535
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "remittance-aurora-security-group"
  }
}


################################################
# security group secondary region
################################################

module "LambdaSecurityGroup_secondary" {
  source = "terraform-aws-modules/security-group/aws"


  name        = "remittance-lambda-security-group"
  description = "Lambda Security Group"
  vpc_id      = module.vpc_secondary.vpc_id

  providers = {
    aws = aws.region2
  }


  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.vpc_cidr_secondary
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.vpc_cidr_secondary
    }
  ]

  egress_with_cidr_blocks = [
    {
      protocol = "-1"
      from_port = 0
      to_port = 65535
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "remittance-lambda-security-group"
  }
}


module "AuroraSecurityGroup_secondary" {
  source = "terraform-aws-modules/security-group/aws"

  providers = {
    aws = aws.region2
  }

  name        = "remittance-lambda-security-group"
  description = "Lambda Security Group"
  vpc_id      = module.vpc_secondary.vpc_id


  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = local.vpc_cidr_secondary
    },
  ]

  egress_with_cidr_blocks = [
    {
      protocol = "-1"
      from_port = 0
      to_port = 65535
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "remittance-aurora-security-group"
  }
}


#############################################
# VPC Peering
#############################################

resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id   = module.vpc_secondary.vpc_id
  vpc_id        = module.vpc.vpc_id
  peer_region   = local.region2
  auto_accept   = false
}

resource "aws_vpc_peering_connection_accepter" "this" {
  provider                  = aws.region2
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "primary_public" {
  route_table_id            = module.vpc.public_route_table_ids[0]
  destination_cidr_block    = local.vpc_cidr_secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "primary_private" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = local.vpc_cidr_secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "secondary_private" {
  route_table_id            = module.vpc_secondary.private_route_table_ids[0]
  destination_cidr_block    = local.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  provider = aws.region2
}

resource "aws_route" "secondary_public" {
  route_table_id            = module.vpc_secondary.public_route_table_ids[0]
  destination_cidr_block    = local.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  provider = aws.region2
}