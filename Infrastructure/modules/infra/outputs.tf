# modules/infra/outputs.tf

# VPC Outputs
output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = [for subnet in aws_subnet.private : subnet.cidr_block]
}

# Bastion Host Outputs
output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

# K3s Nodes Outputs
output "node1_private_ip" {
  description = "Private IP address of node-1 (K3s master)"
  value       = aws_instance.test_private_1.private_ip
}

output "node2_private_ip" {
  description = "Private IP address of node-2 (K3s worker)"
  value       = aws_instance.test_private_2.private_ip
}

# Security Outputs
output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion_sg.id
}

output "private_security_group_id" {
  description = "ID of the private instances security group"
  value       = aws_security_group.private_sg.id
}

# NAT Gateway Outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
