// Unit tests for traffic-rules module

run "plan_redirect_only" {
  command = plan

  variables {
    zone_id = "0123456789abcdef0123456789abcdef"
    redirect_rules = [
      {
        description           = "Redirect /old to /new"
        expression            = "http.request.uri.path eq \"/old\""
        status_code           = 301
        destination           = "https://example.com/new"
        preserve_query_string = true
        enabled               = true
      }
    ]
  }

  assert {
    condition     = resource.cloudflare_ruleset.redirect[0].phase == "http_request_dynamic_redirect"
    error_message = "Redirect ruleset should be created in http_request_dynamic_redirect phase"
  }

  assert {
    condition     = resource.cloudflare_ruleset.redirect[0].rules[0].action == "redirect"
    error_message = "Redirect rule action must be 'redirect'"
  }

  assert {
    condition     = resource.cloudflare_ruleset.redirect[0].rules[0].action_parameters.from_value.status_code == 301
    error_message = "Redirect status_code must be set to 301"
  }

  assert {
    condition     = resource.cloudflare_ruleset.redirect[0].rules[0].action_parameters.from_value.target_url.value == "https://example.com/new"
    error_message = "Redirect destination URL should be mapped to target_url.value"
  }

  assert {
    condition     = resource.cloudflare_ruleset.redirect[0].rules[0].action_parameters.from_value.preserve_query_string == true
    error_message = "preserve_query_string should be true"
  }
}

run "plan_cache_rule" {
  command = plan

  variables {
    zone_id = "0123456789abcdef0123456789abcdef"
    cache_rules = [
      {
        description = "Cache images for 1 hour"
        expression  = "starts_with(http.request.uri.path, \"/media/\")"
        enabled     = true
        cache = {
          ttl                 = 3600
          respect_strong_etag = true
        }
      }
    ]
  }

  assert {
    condition     = resource.cloudflare_ruleset.cache[0].phase == "http_request_cache_settings"
    error_message = "Cache ruleset should be created in http_request_cache_settings phase"
  }

  assert {
    condition     = resource.cloudflare_ruleset.cache[0].rules[0].action == "set_cache_settings"
    error_message = "Cache rule action must be set_cache_settings"
  }

  assert {
    condition     = resource.cloudflare_ruleset.cache[0].rules[0].action_parameters.edge_ttl.default == 3600
    error_message = "edge_ttl.default must be 3600 when ttl is provided"
  }
}

run "plan_rewrite_rule" {
  command = plan

  variables {
    zone_id = "0123456789abcdef0123456789abcdef"
    url_rewrite_rules = [
      {
        description = "Rewrite /blog to /news"
        expression  = "http.request.uri.path eq \"/blog\""
        enabled     = true
        to          = "/news"
      }
    ]
  }

  assert {
    condition     = resource.cloudflare_ruleset.rewrite[0].phase == "http_request_transform"
    error_message = "Rewrite ruleset should be created in http_request_transform phase"
  }

  assert {
    condition     = resource.cloudflare_ruleset.rewrite[0].rules[0].action == "rewrite"
    error_message = "Rewrite rule action must be 'rewrite'"
  }

  assert {
    condition     = resource.cloudflare_ruleset.rewrite[0].rules[0].action_parameters.uri.path.value == "/news"
    error_message = "URI path should be rewritten to /news"
  }
}

run "plan_no_rules_when_empty" {
  command = plan

  variables {
    zone_id           = "0123456789abcdef0123456789abcdef"
    cache_rules       = []
    redirect_rules    = []
    url_rewrite_rules = []
  }

  assert {
    condition     = length(resource.cloudflare_ruleset.cache) == 0
    error_message = "No cache ruleset should be created when cache_rules is empty"
  }

  assert {
    condition     = length(resource.cloudflare_ruleset.redirect) == 0
    error_message = "No redirect ruleset should be created when redirect_rules is empty"
  }

  assert {
    condition     = length(resource.cloudflare_ruleset.rewrite) == 0
    error_message = "No rewrite ruleset should be created when url_rewrite_rules is empty"
  }
}
