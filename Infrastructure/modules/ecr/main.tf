resource "aws_ecr_repository" "this" {
  name = var.aws_ecr_name
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "IMMUTABLE"
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}
