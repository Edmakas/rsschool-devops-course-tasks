variable "prefix" {
  description = "Prefix for resources in AWS"
  type        = string
  default     = "rsschool"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "AWS account ID main module"
  type        = string
}

#modules/infra
variable "vpc_cidr" {
  description = "CIDR for vpc"
  type        = string
}

variable "public_key" {
  description = "SSH public key content for the bastion host"
  type        = string
}

variable "private_key" {
  description = "SSH private key content for the bastion host"
  type        = string
  sensitive   = true
}

variable "node_instance_profile" {
  description = "The name of the IAM instance profile to attach to node-1 for SSM access."
  type        = string
  #default     = "cif-k3s-node-instance-profile"
}
