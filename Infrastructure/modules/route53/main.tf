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
  ttl     = "300"
  records = [var.jenkins_ip_address]
} 