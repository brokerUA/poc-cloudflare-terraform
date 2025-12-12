locals {
  has_cache_rules   = length(var.cache_rules) > 0
  has_redirects     = length(var.redirect_rules) > 0
  has_rewrite_rules = length(var.url_rewrite_rules) > 0
}

resource "cloudflare_ruleset" "cache" {
  count   = local.has_cache_rules ? 1 : 0
  zone_id = var.zone_id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  rules = [
    for rules in var.cache_rules : {
      description = rules.description
      expression  = rules.expression
      enabled     = try(rules.enabled, true)
      action      = "set_cache_settings"
      action_parameters = {
        edge_ttl = try(
          rules.cache.ttl != null ? {
            mode    = "override_origin"
            default = rules.cache.ttl
          } : null,
          null
        )
      }
    }
  ]
}

resource "cloudflare_ruleset" "redirect" {
  count   = local.has_redirects ? 1 : 0
  zone_id = var.zone_id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [
    for rules in var.redirect_rules : {
      description = rules.description
      expression  = rules.expression
      enabled     = try(rules.enabled, true)
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = try(rules.status_code, 301)
          target_url = {
            value = rules.destination
          }
          preserve_query_string = try(rules.preserve_query_string, true)
        }
      }
    }
  ]
}

resource "cloudflare_ruleset" "rewrite" {
  count   = local.has_rewrite_rules ? 1 : 0
  zone_id = var.zone_id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_transform"

  rules = [
    for rules in var.url_rewrite_rules : {
      description = rules.description
      expression  = rules.expression
      enabled     = try(rules.enabled, true)
      action      = "rewrite"
      action_parameters = {
        uri = {
          path = {
            value = rules.to
          }
        }
      }
    }
  ]
}
