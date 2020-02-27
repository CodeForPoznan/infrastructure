resource "aws_iam_user" "empatia" {
  name = "empatia"
}

resource "aws_iam_access_key" "empatia" {
  user = aws_iam_user.empatia.name
}

resource "aws_route53_zone" "empatia" {
    name = "bankempatii.pl"
}

module empatia_ssl_certificate {
  source       = "./ssl_certificate"

  domain       = aws_route53_zone.empatia.name
  route53_zone = aws_route53_zone.empatia
}

module empatia_frontend_assets {
  source    = "./frontend_assets"

  name      = "empatia"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = aws_iam_user.empatia
}

module empatia_cloudfront_distribution {
  source          = "./cloudfront_distribution"

  name            = "empatia"
  domain          = aws_route53_zone.empatia.name
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.empatia
  iam_user        = aws_iam_user.empatia
  acm_certificate = module.empatia_ssl_certificate.certificate

  origins         = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/empatia"
    }
  }
}
