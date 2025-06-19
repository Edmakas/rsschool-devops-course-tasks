variable "prefix" {
  description = "Prefix for resources in AWS"
  type        = string
  default     = "rsschool"
}

variable "project" {
  description = "Project default tag"
  type        = string
  default     = "rs-devops"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "AWS_ACCOUNT_ID" {
  description = "Your 12-digit AWS Account ID"
  type        = string
}

variable "GITHUB_REPO" {
  description = "Trusted Github repo"
  type        = string
}
