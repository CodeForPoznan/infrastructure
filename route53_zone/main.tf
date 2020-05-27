variable "domain" {
  type = string
}

resource "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "ns" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = aws_route53_zone.zone.name
  type    = "NS"
  ttl     = "172800"
  records = [
    "${aws_route53_zone.zone.name_servers.0}.",
    "${aws_route53_zone.zone.name_servers.1}.",
    "${aws_route53_zone.zone.name_servers.2}.",
    "${aws_route53_zone.zone.name_servers.3}.",
  ]
}

resource "aws_route53_record" "soa" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = aws_route53_zone.zone.name
  type    = "SOA"
  ttl     = "900"
  records = [
    "ns-1143.awsdns-14.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

output "zone" {
  value = aws_route53_zone.zone
}
