module codeforpoznan_pl_route53_zone {
  source = "./route53_zone"

  domain = "codeforpoznan.pl"
}

resource "aws_route53_record" "mx_codeforpoznan_pl" {
  zone_id = module.codeforpoznan_pl_route53_zone.zone.zone_id
  name    = module.codeforpoznan_pl_route53_zone.zone.name
  type    = "MX"
  ttl     = "300"
  records = [
    "1 aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
  ]
}

resource "aws_route53_record" "txt_codeforpoznan_pl" {
  zone_id = module.codeforpoznan_pl_route53_zone.zone.zone_id
  name    = module.codeforpoznan_pl_route53_zone.zone.name
  type    = "TXT"
  ttl     = "300"
  records = [
    # https://support.google.com/a/answer/6149686?hl=en&ref_topic=4487770
    "google-site-verification=vEPDPgTFVgeXWQz0ty-fgtOEKowH44Ko8MtyDHTUHRc",

    # https://support.google.com/a/answer/60764
    # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-authentication-spf.html
    "v=spf1 include:_spf.google.com include:amazonses.com ~all",
  ]
}

# https://support.google.com/a/answer/174126
resource "aws_route53_record" "dkim_google" {
  zone_id = module.codeforpoznan_pl_route53_zone.zone.zone_id
  name    = "google._domainkey.codeforpoznan.pl"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnscwqK6IZsq+HPxYzLD46THJ/LYD5Pocv67zg2QJYW040zgAkDVAyYaBgNtS6mNkifWgQtpcMn5x0DfjezBf8rzPUmbXP54TjVwgc8JEqa4d5RUDO6JCvE046KNWdHMmKpia/wm2sAS80cX\"\"9+jD8eVoOkQBT01Dt8TJsisrC5gvncNpFHk1Hl254fHc/njn7opWMTMIu1i9xSzjtttR37SnxCtI7xKecG7MtjFHpG5W98C8EefI71t5BKve+AmirGVSrNyedraVbX9JQ8S0tCwnM27+/KqFDpalV9smKkBY/m/Aewm1m7OJHnqxiwDW6/w8f3CjU1dbF/LLSYABnOQIDAQAB",
  ]
}

# https://support.google.com/a/answer/2466563
resource "aws_route53_record" "dmarc" {
  zone_id = module.codeforpoznan_pl_route53_zone.zone.zone_id
  name    = "_dmarc.codeforpoznan.pl"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=DMARC1; p=reject; rua=mailto:hello@codeforpoznan.pl; pct=100"
  ]
}

