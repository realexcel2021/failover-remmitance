provider "aws" {
  region = local.region1

}

provider "aws" {
  region = local.region2
  alias  = "region2"

}


locals {
  region1 = "us-east-1"
  region2 = "us-west-2"
  name  = "remittance-project"
  domain = "devopslord.com"
  api_domain = "demo.devopslord.com"
  ui_domain = "demoui.devopslord.com" 
  vpc_cidr = "10.1.0.0/16"
  vpc_cidr_secondary = "10.2.0.0/16"
  azs                          = slice(data.aws_availability_zones.available.names, 0, 3)
  azs_secondary                = slice(data.aws_availability_zones.secondary.names, 0, 3) 
  tags = {
    Project  = "remittance-project"
  }

}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_availability_zones" "secondary" {
  provider = aws.region2
}