terraform {
  backend "s3" {
    bucket       = "rstfstatecif"
    key          = "tf-state"
    region       = "us-west-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}
