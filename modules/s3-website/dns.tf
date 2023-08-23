resource "aws_route53_record" "website_alias" {
  zone_id = var.dns_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.website.domain_name
    zone_id = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_cname" {
  zone_id = var.dns_zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = [
     var.domain_name
  ]
}