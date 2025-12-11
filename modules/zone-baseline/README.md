# zone-baseline module

Apply baseline configuration for a Cloudflare zone:
- Manage Zone Settings via `cloudflare_zone_setting` (supports mixed value types).
- Create DNS records in the zone from a typed list.

The module uses per-setting resources and a deterministic map for DNS records to ensure stable plans.

## Prerequisites
- Terraform >= 1.5.0 and the Cloudflare provider >= 5.0.0 (declared in `versions.tf`).
- A Cloudflare API token with permissions to manage Zone Settings and DNS for the target zone.
- Your Cloudflare `zone_id`.

Example provider configuration:

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

## Inputs
- `zone_id` (string, required)
  - Cloudflare Zone ID to manage.

- `settings` (map(any), optional, default: `{}`)
  - Map of Cloudflare zone settings to apply using per-setting resources. Values can be string, number, bool, list, or object depending on the setting.
  - Special case: set key `ssl_recommender` to a boolean and it will be applied via the `enabled` attribute (provider requires `enabled` for this setting).

- `dns_records` (list(object), optional, default: `[]`)
  - List of DNS records to create in the zone. Optional fields can be null.
  - Object fields:
    - `name` (string, required)
    - `type` (string, required) — e.g., `A`, `AAAA`, `CNAME`, `TXT`, etc.
    - `content` (string, required)
    - `ttl` (number, optional) — defaults to `1` (Cloudflare "automatic") when not provided
    - `proxied` (bool, optional)
    - `priority` (number, optional)
    - `comment` (string, optional)
    - `tags` (list(string), optional)

## Outputs
- `dns_record_ids`
  - Map of DNS record resource IDs keyed by a synthetic key (`<name>_<type>_<index>`).

## Minimal example

```hcl
variable "cloudflare_api_token" { type = string }

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "zone_baseline" {
  source  = "../zone-baseline"
  zone_id = "<ZONE_ID>"

  # Apply a few common zone settings
  settings = {
    always_use_https = "on"
    brotli            = "on"
    min_tls_version   = "1.2"
    ssl               = "full"

    # Special case handled by the module: uses `enabled` under the hood
    ssl_recommender = true
  }

  # Create a couple of DNS records
  dns_records = [
    {
      name    = "@"
      type    = "A"
      content = "203.0.113.10"
      proxied = true
    },
    {
      name    = "www"
      type    = "CNAME"
      content = "example.com"
      ttl     = 300
    }
  ]
}

output "dns_record_ids" {
  value = module.zone_baseline.dns_record_ids
}
```

## Notes
- Zone settings are applied per key using `cloudflare_zone_setting` and support mixed types as required by the provider.
- The `ssl_recommender` setting is applied via `enabled` and forces `value = "on"` as required by the Cloudflare provider.
- DNS records default `ttl` to `1` (automatic) when not provided.
- DNS resources use a deterministic synthetic key to avoid collisions and keep plans stable when list order changes.
