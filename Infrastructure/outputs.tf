# Root module outputs

# output "vpc_cidr_block" {
#   description = "The CIDR block of the main VPC"
#   value       = module.infra.vpc_cidr_block
# }

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = module.infra.public_subnet_cidrs
}


output "node-1_public_ip" {
  description = "Public IP address of the node-1 host"
  value       = module.infra.node-1_public_ip
}

# output "node-2_public_ip" {
#   description = "Public IP address of the node-2 host"
#   value       = module.infra.node-2_public_ip
# }

output "node-1_private_ip" {
  description = "Private IP address of the node-1 host"
  value       = module.infra.node-1_private_ip
}

# output "node-2_private_ip" {
#   description = "Private IP address of the node-2 host"
#   value       = module.infra.node-2_private_ip
# }

# Route53 outputs
output "jenkins_dns_name" {
  description = "The DNS name for Jenkins"
  value       = module.route53.jenkins_dns_name
}

output "jenkins_dns_fqdn" {
  description = "The fully qualified domain name for Jenkins"
  value       = module.route53.jenkins_dns_fqdn
}
