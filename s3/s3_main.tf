resource "aws_s3_bucket" "staging" {
  bucket = "staging-${random_string.bucket_suffix.result}"
  
  tags = var.tags
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "staging" {
  bucket = aws_s3_bucket.staging.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "staging" {
  bucket = aws_s3_bucket.staging.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.staging.id
}

output "bucket_arn" {
  value = aws_s3_bucket.staging.arn
} 