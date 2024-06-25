module "acm_api" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${local.api_domain}"
  zone_id     = aws_route53_zone.api.id
}

module "acm_api_sec" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  

  providers = {
    aws = aws.region2
  }

  domain_name = "${local.api_domain}"
  zone_id     = aws_route53_zone.api.id
}

module "acm_ui" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${local.ui_domain}"
  zone_id     = aws_route53_zone.ui.id
}