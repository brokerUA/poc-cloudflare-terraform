# workers module

Deploy a Cloudflare Worker script and optionally attach it to one or more HTTP routes in a zone.

The module:

- Creates a Worker script in the specified Cloudflare account.
- Optionally creates one or more Worker routes in the specified zone and binds them to the script.
- Supports binding plaintext environment variables to the script.

## Prerequisites

- Terraform >= 1.5.0 and the Cloudflare provider >= 5.0.0 (declared in `versions.tf`).
- A Cloudflare API token with permissions to manage Workers and Routes for the target account and zone.
  - Required scopes typically include access to Workers Scripts and Routes.
- Your Cloudflare `account_id` and `zone_id`.

Example provider configuration:

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

## Inputs

- `account_id` (string, required)
  - Cloudflare Account ID where the Worker script will be deployed.

- `zone_id` (string, required)
  - Cloudflare Zone ID where the Worker route(s) will be created.

- `script_name` (string, required)
  - Name of the Worker script.

- `script_content` (string, required)
  - Inline Worker script content. You can load from a file using `file("path/to/script.js")`.

- `main_module` (string, optional, default: `"index.js"`)
  - Path of the Worker script's main module. Useful for modules or ES module workers.

- `plain_text_vars` (map(string), optional, default: `{}`)
  - Map of plaintext environment variables to bind to the Worker script (`name => value`).

- `route_patterns` (list(string), optional, default: `[]`)
  - List of route patterns to attach the Worker (e.g., `["example.com/*", "www.example.com/*"]`). Routes are only created when `create_route` is `true` and this list (or the deprecated `route_pattern`) is non-empty.

- `create_route` (bool, optional, default: `true`)
  - Whether to create Worker routes. If `false`, only the script will be created.

- `route_pattern` (string, optional, default: `null`) — DEPRECATED
  - Single route pattern to attach the Worker. Prefer `route_patterns`.

## Outputs

- `worker_script_name`
  - Name of the deployed Worker script.

- `worker_route_ids`
  - Map of Worker route IDs keyed by route pattern. Empty if no routes are created.

- `worker_route_id`
  - Backward-compatible single route ID (first if multiple, `null` if none).

## Minimal example

```hcl
variable "cloudflare_api_token" { type = string }

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "workers_example" {
  source      = "../workers"
  account_id  = "<ACCOUNT_ID>"
  zone_id     = "<ZONE_ID>"
  script_name = "maintenance"

  # Load inline content from a local file
  script_content = file("${path.module}/worker-scripts/maintenance.js")

  # Bind environment variables as plaintext bindings
  plain_text_vars = {
    MAINTENANCE = "true"
  }

  # Attach the script to multiple host patterns
  route_patterns = [
    "example.com/*",
    "www.example.com/*",
  ]
}

output "worker_script_name" {
  value = module.workers_example.worker_script_name
}
```

## Notes

- Routes are created only when `create_route` is `true` and at least one effective pattern is provided via `route_patterns` (preferred) or the deprecated `route_pattern`.
- The module uses Cloudflare provider v5 resources `cloudflare_workers_script` and `cloudflare_workers_route`.
- Only plaintext variable bindings are supported here; for secrets or KV bindings, extend the module accordingly.
