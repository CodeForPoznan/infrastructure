resource "aws_iam_user" "empatia" {
  name = "empatia"
}

resource "aws_iam_access_key" "empatia" {
  user = aws_iam_user.empatia.name
}

resource "aws_route53_zone" "empatia" {
  name = "bankempatii.pl"
}

resource "aws_route53_record" "a_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = aws_route53_zone.empatia.name
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = "d6cxmr8432pje.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
  }
}

resource "aws_route53_record" "a_www_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = "www.${aws_route53_zone.empatia.name}"
  type    = "A"
  ttl     = "300"
  records = [
    "176.31.162.42",
  ]
}

resource "aws_route53_record" "mx_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = aws_route53_zone.empatia.name
  type    = "MX"
  ttl     = "300"
  records = [
    "1 redirect.ovh.net",
  ]
}

resource "aws_route53_record" "mx_www_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = "www.${aws_route53_zone.empatia.name}"
  type    = "MX"
  ttl     = "300"
  records = [
    "1 redirect.ovh.net",
  ]
}

resource "aws_route53_record" "ns_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = aws_route53_zone.empatia.name
  type    = "NS"
  ttl     = "172800"
  records = [
    "ns-214.awsdns-26.com",
    "ns-1083.awsdns-07.org",
    "ns-1596.awsdns-07.co.uk",
    "ns-854.awsdns-42.net",
  ]
}

resource "aws_route53_record" "soa_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = aws_route53_zone.empatia.name
  type    = "SOA"
  ttl     = "900"
  records = [
    "ns-1596.awsdns-07.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

resource "aws_route53_record" "cname_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = "_ac65bc401f2ef9831b5de3354b6cc298.${aws_route53_zone.empatia.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "_99b56888aa18364008e7b7ca51d0325c.ltfvzjuylp.acm-validations.aws",
  ]
}

resource "aws_route53_record" "txt_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = aws_route53_zone.empatia.name
  type    = "TXT"
  ttl     = "300"
  records = [
    "\"1|www.${aws_route53_zone.empatia.name}\"",
    "\"v=spf1 include:mx.ovh.com ~all\"",
  ]
}

resource "aws_route53_record" "txt_www_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = "www.${aws_route53_zone.empatia.name}"
  type    = "TXT"
  ttl     = "300"
  records = [
    "\"3|welcome\"",
    "\"l|pl\"",
  ]
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
