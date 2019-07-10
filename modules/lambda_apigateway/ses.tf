variable "domain" {}
variable "zone_id" {}



resource "aws_ses_domain_identity" "ses_domain_identity" {
  domain = "${var.domain}"
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = "${var.zone_id}"
  name    = "_amazonses.example.com"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.ses_domain_identity.verification_token}"]
}
