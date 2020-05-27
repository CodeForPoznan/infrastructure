resource "aws_route53_record" "pah_fm" {
  zone_id = module.codeforpoznan_pl_route53_zone.zone.zone_id
  name    = "pahfm.codeforpoznan.pl."
  type    = "A"
  ttl     = "300"
  records = [
    "52.232.62.212",
  ]
}

resource "aws_route53_record" "wildcard_pah_fm" {
  zone_id = module.codeforpoznan_pl_route53_zone.zone.zone_id
  name    = "*.pahfm.codeforpoznan.pl."
  type    = "A"
  ttl     = "300"
  records = [
    "52.232.62.212",
  ]
}
