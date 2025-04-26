resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucketname
  tags   = var.tags

  lifecycle {
    prevent_destroy = false
  }
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3bucket_encryption" {
  bucket = aws_s3_bucket.s3bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.s3bucket.id

  rule {
    id     = "TransitionToIA"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
