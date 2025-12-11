locals {
  zone_settings = var.settings
}

# Manage zone settings using per-setting resources. Supports mixed types:
# - string, number, list, and object `value`
# - special case: `ssl_recommender` uses `enabled` instead of `value`

resource "cloudflare_zone_setting" "settings" {
  for_each = { for k, v in local.zone_settings : k => v if k != "ssl_recommender" }

  zone_id    = var.zone_id
  setting_id = each.key
  value      = each.value
}

resource "cloudflare_zone_setting" "ssl_recommender" {
  for_each = lookup(local.zone_settings, "ssl_recommender", null) != null ? {
    "ssl_recommender" = lookup(local.zone_settings, "ssl_recommender", null)
  } : {}

  zone_id    = var.zone_id
  setting_id = "ssl_recommender"
  value      = "on"
  enabled    = each.value
}

locals {
  # Build deterministic keys for DNS records and map to their index in the input list.
  dns_index_map = {
    for idx, r in var.dns_records : "${r.name}_${r.type}_${idx}" => idx
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = local.dns_index_map

  # Access the typed object from the input list via its index for reliable static analysis.
  zone_id = var.zone_id
  name    = var.dns_records[each.value].name
  type    = var.dns_records[each.value].type
  content = var.dns_records[each.value].content

  # Cloudflare provider requires ttl; default to 1 (automatic) if not provided
  ttl      = coalesce(var.dns_records[each.value].ttl, 1)
  proxied  = try(var.dns_records[each.value].proxied, null)
  priority = try(var.dns_records[each.value].priority, null)
  comment  = try(var.dns_records[each.value].comment, null)
  tags     = try(var.dns_records[each.value].tags, null)
}
