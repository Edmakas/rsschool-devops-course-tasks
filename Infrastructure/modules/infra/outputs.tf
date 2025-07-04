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

# K3s Nodes Outputs

output "node-1_public_ip" {
  description = "Public IP address of node-1 (K3s master)"
  value       = aws_instance.node-1.public_ip
}

# output "node-2_public_ip" {
#   description = "Public IP address of node-2 (K3s worker)"
#   value       = aws_instance.node-2.public_ip
# }

output "node-1_private_ip" {
  description = "Private IP address of node-1 (K3s master)"
  value       = aws_instance.node-1.private_ip
}

# output "node-2_private_ip" {
#   description = "Private IP address of node-2 (K3s worker)"
#   value       = aws_instance.node-2.private_ip
# }
