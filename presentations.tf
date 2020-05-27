resource "aws_iam_user" "presentations" {
  name = "presentations"
}

resource "aws_iam_access_key" "presentations" {
  user = aws_iam_user.presentations.name
}

module presentations_ssl_certificate {
  source = "./ssl_certificate"

  domain       = "slides.codeforpoznan.pl"
  route53_zone = module.codeforpoznan_pl_route53_zone.zone
}

module presentations_frontend_assets {
  source = "./frontend_assets"

  name      = "Presentations"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = aws_iam_user.presentations
}

module presentations_cloudfront_distribution {
  source = "./cloudfront_distribution"

  name            = "Presentations"
  domain          = "slides.codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = module.codeforpoznan_pl_route53_zone.zone
  iam_user        = aws_iam_user.presentations
  acm_certificate = module.presentations_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/Presentations"
    }
  }
}
