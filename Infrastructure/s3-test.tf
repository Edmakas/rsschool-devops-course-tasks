resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "${local.prefix}-${random_id.suffix.hex}"
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.test_bucket.bucket
}
