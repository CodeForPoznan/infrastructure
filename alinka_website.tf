resource "aws_iam_user" "alinka_website" {
  name = "alinka_website"
}

resource "aws_iam_access_key" "alinka_website" {
  user = aws_iam_user.alinka_website.name
}

module alinka_website_route53_zone {
  source = "./route53_zone"

  domain = "alinka.io"
}

module alinka_website_ssl_certificate {
  source = "./ssl_certificate"

  domain       = "alinka.io"
  route53_zone = module.alinka_website_route53_zone.zone
}

module alinka_website_frontend_assets {
  source = "./frontend_assets"

  name      = "alinka_website"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = aws_iam_user.alinka_website
}

module alinka_website_cloudfront_distribution {
  source = "./cloudfront_distribution"

  name            = "alinka_website"
  domain          = "alinka.io"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = module.alinka_website_route53_zone.zone
  iam_user        = aws_iam_user.alinka_website
  acm_certificate = module.alinka_website_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/alinka_website"
    }
    google_form = {
      domain_name   = "docs.google.com"
      origin_path   = ""
      custom_origin = true
    }
  }

  additional_cache_behaviors = [
    {
      path_pattern     = "forms/*"
      target_origin_id = "google_form"
    }
  ]
}
