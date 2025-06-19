variable "prefix" {
  description = "Prefix for resources in AWS"
  type        = string
  default     = "udemy"
}

variable "project" {
  description = "Project default tag"
  type        = string
  default     = "udemy-hands-on"
}

variable "tf_bucket" {
  description = "S3 bucket for state"
  type        = string
  default     = "udemytfstate"
}

variable "tf_bucket_key" {
  description = "S3 bucket key for state"
  type        = string
  default     = "tf-state"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "111"
}

#modules/infra
variable "vpc_cidr" {
  description = "CIDR for vpc"
  type        = string
}

# variable "key_name" {
#   description = "Name of SSH public key file for the bastion host"
#   type        = string
# }

variable "public_key" {
  description = "SSH public key content for the bastion host"
  type        = string
}
