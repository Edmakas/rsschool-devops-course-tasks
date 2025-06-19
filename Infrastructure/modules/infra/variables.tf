# modules/infra/variables.tf
variable "vpc_cidr" {
  description = "modules/infra/variables.tf"
  type        = string
}

variable "prefix" {
  description = "Prefix for resources in AWS"
  type        = string
  default     = "udemy"
}

variable "public_key" {
  description = "SSH Public key content to use for the bastion host"
  type        = string
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Warning: This allows access from anywhere. Restrict in production!
}

