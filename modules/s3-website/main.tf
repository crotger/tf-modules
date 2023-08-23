variable "domain_name" {
  type        = string
  description = "dns name for this website"
}

variable "s3_root_path" {
  type        = string
  description = "S3 path that should begin the index of the webiste"
  default     = ""
}

variable "dns_zone_id" {
  type = string
  description = "Zone ID of a route53 zone that hosts var.domain_name"
}

variable "certificate_arn" {
  type = string
  description = "ARN of an AWS certificate to use for TLS"
}

locals {
  s3_public_path = var.s3_root_path != "" ? join("/", ["/", var.s3_root_path, "*"]) : "/*"
}

resource "aws_s3_bucket" "website" {
  bucket = var.domain_name
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"

    # routing rules = 
  }
}

data "aws_iam_policy_document" "website_bucket_policy" {
  statement {
    sid    = "AllowCloudfrontReadObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.website.arn}${local.s3_public_path}"
    ]
    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website_s3_access.iam_arn]
    }
  }

  statement {
    sid    = "AllowCloudfrontListObjects"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.website.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "${var.s3_root_path}*",
      ]
    }
    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website_s3_access.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = data.aws_iam_policy_document.website_bucket_policy.json
}

output "bucket" {
  value = aws_s3_bucket.website
}
