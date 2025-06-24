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

variable "ips_to_bastion" {
  description = "List of CIDR blocks allowed to SSH to the bastion host"
  type        = list(string)
}

variable "public_key" {
  description = "SSH public key content for the bastion host"
  type        = string
}
