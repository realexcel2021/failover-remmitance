##########################
# recovery cluster
##########################

resource "aws_route53recoverycontrolconfig_cluster" "this" {
  name = "${local.name}-cluster-terraform"
}

resource "aws_route53recoverycontrolconfig_control_panel" "this" {
  name        = "${local.name}-ControlPanel-terraform"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.this.arn
}

resource "aws_route53recoverycontrolconfig_routing_control" "this1" {
  name              = "${local.name}-region1"
  cluster_arn       = aws_route53recoverycontrolconfig_cluster.this.arn
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.this.arn
}

resource "aws_route53recoverycontrolconfig_routing_control" "this2" {
  name              = "${local.name}-region2"
  cluster_arn       = aws_route53recoverycontrolconfig_cluster.this.arn
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.this.arn
}


#############################
# health checks
#############################

resource "aws_route53_health_check" "region1" {
  type              = "RECOVERY_CONTROL"
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.this1.arn

  tags = {
    Name = "${local.name}-RoutingControlHealthcheck1"
  }
}

resource "aws_route53_health_check" "region2" {
  type              = "RECOVERY_CONTROL"
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.this2.arn

  tags = {
    Name = "${local.name}-RoutingControlHealthcheck2"
  }
}

#########################################
#  hosted zones
#########################################

data "aws_route53_zone" "selected" {
  name         = local.domain
  private_zone = false
}

####################################
# api domain name
####################################

resource "aws_route53_zone" "api" {
  name = local.api_domain
}

resource "aws_route53_record" "api-ns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.api_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.api.name_servers
}

####################################
# UI domain name
####################################

resource "aws_route53_zone" "ui" {
  name = local.ui_domain
}

resource "aws_route53_record" "ui-ns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.ui_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.ui.name_servers
}
