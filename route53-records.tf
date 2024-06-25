resource "aws_route53_record" "api-region1" {
  zone_id = aws_route53_zone.api.zone_id
  name    = "${local.api_domain}"
  type    = "A"
  health_check_id = aws_route53_health_check.region1.id
  set_identifier = "Primary"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
  }

  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "api-region2" {
  zone_id = aws_route53_zone.api.zone_id
  name    = "${local.api_domain}"
  type    = "A"
  health_check_id = aws_route53_health_check.region1.id
  set_identifier = "Secondary"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this_sec.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this_sec.regional_zone_id
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.ui.zone_id
  name    = "${local.ui_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}