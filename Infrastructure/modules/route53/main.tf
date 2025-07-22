# Route53 module for managing DNS records

# Data source to get the hosted zone
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# Create A record for Jenkins
resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "jenkins"
  type    = "A"
  ttl     = "60"
  records = [var.jenkins_ip_address]
}

resource "aws_route53_record" "flaskapp" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "flask-app"
  type    = "A"
  ttl     = "60"
  records = [var.jenkins_ip_address]
}

resource "aws_route53_record" "sonar" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "sonar"
  type    = "A"
  ttl     = "60"
  records = [var.jenkins_ip_address]
}

resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "prom.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.jenkins_ip_address]
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "grafana.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.jenkins_ip_address]
}

resource "aws_route53_record" "node1" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "node1"
  type    = "A"
  ttl     = 300
  records = [var.jenkins_ip_address]
}
