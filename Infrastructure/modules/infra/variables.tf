# modules/infra/variables.tf
variable "vpc_cidr" {
  description = "modules/infra/variables.tf"
  type        = string
}

variable "prefix" {
  description = "Prefix for resources in AWS"
  type        = string
  default     = "rsschool"
}

variable "public_key" {
  description = "SSH Public key content to use for the bastion host"
  type        = string
}

variable "private_key" {
  description = "SSH private key content"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to hosts"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_profile" {
  description = "The name of the IAM instance profile to attach to node-1 for SSM access."
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources and scripts."
  type        = string
}
