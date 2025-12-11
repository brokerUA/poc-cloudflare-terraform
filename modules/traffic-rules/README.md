# traffic-rules module

Create and manage Cloudflare Rulesets for a zone to handle:
- Cache settings (phase `http_request_cache_settings`)
- URL redirects (phase `http_request_dynamic_redirect`)
- URL rewrites (phase `http_request_transform`)

The module only creates a ruleset for a phase when you provide at least one rule for that phase. Each ruleset is created at the zone level and named `default`.

## Prerequisites
- Terraform `>= 1.5.0` and the Cloudflare provider `>= 5.0.0` (declared in `versions.tf`).
- A Cloudflare API token with permission to manage rulesets for the target zone.
- Your Cloudflare `zone_id`.

Example provider configuration:

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

## Inputs
- `zone_id` (string, required)
  - Cloudflare Zone ID where the rulesets will be applied.

- `cache_rules` (list(object), optional, default: `[]`)
  - Rules for the `http_request_cache_settings` phase. Each object supports:
    - `description` (string, optional, default: `"cache rule"`)
    - `expression` (string, required) — Cloudflare filter expression (e.g., `http.request.uri.path matches \/assets\/.*`).
    - `enabled` (bool, optional, default: `true`)
    - `cache` (object, optional, default: `null`) — basic cache parameters:
      - `ttl` (number, optional) — TTL in seconds. When provided, the module sets `edge_ttl` with mode `override_origin`.
      - `cache_by_device` (bool, optional) — currently not applied by this module.
      - `respect_strong_etag` (bool, optional) — currently not applied by this module.
  - Note: At present, the module only uses `cache.ttl` when rendering the action parameters.

- `redirect_rules` (list(object), optional, default: `[]`)
  - Rules for the `http_request_dynamic_redirect` phase. Each object supports:
    - `description` (string, optional, default: `"redirect rule"`)
    - `expression` (string, required)
    - `enabled` (bool, optional, default: `true`)
    - `status_code` (number, optional, default: `301`)
    - `destination` (string, required) — Target URL for redirection.
    - `preserve_query_string` (bool, optional, default: `true`)

- `url_rewrite_rules` (list(object), optional, default: `[]`)
  - Rules for the `http_request_transform` phase with a `rewrite` action. Each object supports:
    - `description` (string, optional, default: `"rewrite rule"`)
    - `expression` (string, required)
    - `enabled` (bool, optional, default: `true`)
    - `to` (string, required) — New path to rewrite to (sets `action_parameters.uri.path.value`).

## Outputs
- `cache_ruleset_id`
  - ID of the cache ruleset (or `null` if not created).
- `redirect_ruleset_id`
  - ID of the redirect ruleset (or `null` if not created).
- `rewrite_ruleset_id`
  - ID of the rewrite ruleset (or `null` if not created).

## Minimal example

```hcl
variable "cloudflare_api_token" { type = string }

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "traffic_rules" {
  source  = "../traffic-rules"
  zone_id = "<ZONE_ID>"

  cache_rules = [
    {
      description = "Cache static assets for 1 hour"
      expression  = "http.request.uri.path matches \\.(?:css|js|png|jpg|gif|svg)$"
      cache = {
        ttl = 3600
      }
    }
  ]

  redirect_rules = [
    {
      description = "Redirect old blog to new domain"
      expression  = "http.host eq \"blog.example.com\""
      status_code = 301
      destination = "https://new-blog.example.com"
    }
  ]

  url_rewrite_rules = [
    {
      description = "Rewrite /old/* to /new/* on same host"
      expression  = "starts_with(http.request.uri.path, \"/old/\")"
      to          = "/new/${substring(http.request.uri.path, 5)}"
    }
  ]
}

output "cache_ruleset_id" {
  value = module.traffic_rules.cache_ruleset_id
}
```

## Notes
- Rulesets are only created when their corresponding input lists are non-empty.
- All rulesets are created with `kind = "zone"` and name `default`.
- Ensure your filter `expression` strings are valid Cloudflare expressions for the respective phase.
- Some optional fields defined in inputs (like `cache_by_device` and `respect_strong_etag`) are present for future extension but are not currently applied by this module.