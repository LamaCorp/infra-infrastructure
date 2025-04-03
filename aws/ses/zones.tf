locals {
  zones = toset([
    "as212024.net",
    "devou.ps",
    "lama-corp.space",
    "lama.tel",
    "marcerisson.space",
    "risson.me",
    "risson.space",
    "rplace.space",
    "thefractal.space",
  ])
}

data "cloudflare_zone" "this" {
  for_each = local.zones
  name     = each.key
}

resource "aws_ses_domain_identity" "this" {
  for_each = local.zones
  domain   = each.key
}

resource "aws_ses_domain_dkim" "this" {
  for_each = local.zones
  domain   = aws_ses_domain_identity.this[each.key].domain
}

resource "cloudflare_record" "this" {
  for_each = merge([
    for zone in local.zones : {
      for token in aws_ses_domain_dkim.this[zone].dkim_tokens :
      "${zone}_${token}" => {
        zone  = zone
        token = token
      }
    }
  ]...)

  zone_id = data.cloudflare_zone.this[each.value.zone].id
  name    = "${each.value.token}._domainkey"
  type    = "CNAME"
  value   = "${each.value.token}.dkim.amazonses.com"
}

resource "aws_ses_domain_identity_verification" "this" {
  for_each = local.zones
  domain   = aws_ses_domain_identity.this[each.key].id

  depends_on = [
    cloudflare_record.this,
  ]
}
