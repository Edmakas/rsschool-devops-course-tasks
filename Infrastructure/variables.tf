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

variable "tf_bucket" {
  description = "S3 bucket for state"
  type        = string
  default     = "rstfstatecif"
}

variable "tf_bucket_key" {
  description = "S3 bucket key for state"
  type        = string
  default     = "tf-state"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "AWS_ACCOUNT_ID" {
  description = "AWS account ID - Required for GitHub Actions role assumption. Set this as a GitHub secret named AWS_ACCOUNT_ID."
  type        = string
}

variable "GithubActionsRole" {
  description = "IAM role for Github Actions"
  type        = string
}
