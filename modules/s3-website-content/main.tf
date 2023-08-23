variable "content_folder" {
  type = string
  description = "contents to upload to S3"
}

variable "s3_root_path" {
  type = string
  description = "root folder to upload to in S3"
  default = ""
}

variable "bucket" {
  type = any
}

locals {
  local_content_base  = var.content_folder
  remote_content_base = var.s3_root_path
  files = fileset(local.local_content_base, "**")

  mime_types = {
    ".html" = "text/html"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
  }

  # default_mime_type = "binary/octet-stream"
}

resource "aws_s3_object" "website_files" {
  for_each = local.files
  bucket = var.bucket.bucket
  key = "${local.remote_content_base}/${each.value}"
  source = "${local.local_content_base}/${each.value}"

  etag = filemd5("${local.local_content_base}/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}

output "files" {
  value = local.files
}

output "objects" {
  value = aws_s3_object.website_files.*
}