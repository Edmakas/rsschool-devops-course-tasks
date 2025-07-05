output "jenkins_dns_name" {
  description = "The DNS name for Jenkins"
  value       = aws_route53_record.jenkins.name
}

output "jenkins_dns_fqdn" {
  description = "The fully qualified domain name for Jenkins"
  value       = aws_route53_record.jenkins.fqdn
} 