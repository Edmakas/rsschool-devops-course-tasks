# Root module outputs

# output "vpc_cidr_block" {
#   description = "The CIDR block of the main VPC"
#   value       = module.infra.vpc_cidr_block
# }

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = module.infra.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = module.infra.private_subnet_cidrs
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = module.infra.bastion_public_ip
}

output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = module.infra.bastion_security_group_id
}

output "private_security_group_id" {
  description = "ID of the private instances security group"
  value       = module.infra.private_security_group_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.infra.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = module.infra.nat_gateway_public_ip
}
