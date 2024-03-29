# AWS S3 bucket for static hosting
resource "aws_s3_bucket" "website" {
  bucket = "${var.website_bucket_name}"
  acl = "public-read"

  tags {
    Name = "Website"
    Environment = "production"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT","POST"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::digbick-ui/*"
    }
  ]
}
EOF

  website {
    index_document = "producer.html"
    error_document = "www.google.com"
  }
}

# Executing AWS S3 CLI Command Sync to copy UI folder into Digbick-ui bucket

resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ui s3://digbick-ui"
  }
}

resource "aws_s3_bucket" "lda-athena" {
  bucket = "lda-athena"
  tags = "${merge(
    local.common_tags
  )}"
}

resource "aws_s3_bucket" "glue-bucket" {
  bucket = "lda-glue-script"
  tags = "${merge(
    local.common_tags
  )}"
}

resource "null_resource" "upload-glue-script-to-s3" {
  provisioner "local-exec" {
    command = "aws s3 sync glue s3://lda-glue-script"
  }
}

resource "aws_s3_bucket" "raw-bucket" {
  bucket = "lda-s3-raw"
  tags = "${merge(
    local.common_tags,
    local.kinesis_module_tags
  )}"
}

resource "aws_s3_bucket" "conform-bucket" {
  bucket = "lda-s3-conform"
  tags = "${merge(
    local.common_tags,
    local.kinesis_module_tags
  )}"
}