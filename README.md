# Terraform Cloudflare Modules (POC)

This repository is a Proof of Concept (POC) for managing Cloudflare configuration using Terraform. It provides a small set of reusable Terraform modules, plus an example composition that demonstrates how to configure common Cloudflare resources without applying against real APIs in tests.

The repo is optimized for reproducible local workflows and module‑level testing using Terraform's native test framework.

## Features
- Modular `modules/*`:
  - `zone-baseline`: baseline zone settings (e.g., Image Resizing and other zone settings via provider v5 resources)
  - `workers`: deploy a Cloudflare Worker script and optionally attach HTTP routes
  - `traffic-rules`: traffic management using Ruleset Engine
  - `origin-ca`: manage Origin CA certificates (plan‑time tested)
- Example under `examples/complete/` showing how to compose the modules together (including Workers scripts from `examples/complete/worker-scripts/*`).
- Reproducible tooling via `mise.toml` and pinned versions.
- Terraform native tests (`.tftest.hcl`) per module that validate plans without calling Cloudflare APIs.

## Stack and Tooling
- IaC: Terraform (language: HCL)
- Provider: Cloudflare provider v5 (pinned per module in `versions.tf`)
- Tool/version manager: `mise` (recommended)
- Optional runtime for Worker script authoring: Node.js (only needed if you develop Worker scripts; not required for planning/tests)

Pinned versions (see `mise.toml`):
- `terraform = 1.14.1`
- `node = 22.11.0` (optional)

## Requirements
- Terraform >= 1.5.0 (project develops and tests with 1.14.1 via `mise`)
- Cloudflare provider >= 5.0.0 (resolved during `terraform init` in each module)
- To apply the example against a real Cloudflare account you need a Cloudflare API token with appropriate permissions.

Environment variables when applying (not needed for tests):
- `CLOUDFLARE_API_TOKEN` — API token used by the provider in `examples/complete/provider.tf`.

## Getting Started

### Option A: Using mise (recommended)
1. Install `mise` (https://mise.jdx.dev/) and run in a shell where `mise` activates the pinned tools.
2. Format all Terraform code:
   - `mise run fmt`
3. Initialize the example composition (no backend configured):
   - `mise run init`
4. Validate and plan:
   - `mise run validate`
   - `mise run plan`
5. Apply (requires valid Cloudflare credentials in your environment; do not apply against production without review):
   - `mise run apply`

### Option B: Without mise
Ensure Terraform >= 1.5.0 (1.14.1 preferred) is on PATH.

- Format:
  - `terraform fmt -recursive`
- Initialize, validate, plan (example composition):
  - `terraform -chdir=examples/complete init`
  - `terraform -chdir=examples/complete validate`
  - `terraform -chdir=examples/complete plan`
- Apply (credentials required):
  - `terraform -chdir=examples/complete apply`

## Scripts and Tasks
Defined in `mise.toml`:
- `fmt` — `terraform fmt -recursive`
- `init` — `terraform -chdir=examples/complete init`
- `validate` — `terraform -chdir=examples/complete validate`
- `plan` — `terraform -chdir=examples/complete plan`
- `apply` — `terraform -chdir=examples/complete apply`
- `test` — runs init+test for each module sequentially using Terraform native tests

## Testing
This repo uses Terraform native tests (no external harness). Tests operate at plan time and do not call Cloudflare APIs.

Run all module tests:

```
mise run test
```

Under the hood it executes (abbreviated):

```
terraform -chdir=modules/zone-baseline init -backend=false -upgrade && terraform -chdir=modules/zone-baseline test -verbose && \
terraform -chdir=modules/workers init -backend=false -upgrade && terraform -chdir=modules/workers test -verbose && \
terraform -chdir=modules/traffic-rules init -backend=false -upgrade && terraform -chdir=modules/traffic-rules test -verbose && \
terraform -chdir=modules/origin-ca init -backend=false -upgrade && terraform -chdir=modules/origin-ca test -verbose
```

Run tests for a single module:

```
terraform -chdir=modules/<module> init -backend=false -upgrade
terraform -chdir=modules/<module> test -verbose
```

Notes specific to the Cloudflare provider v5 used here:
- Some resources are not destroyable by Terraform once created; tests rely on plan‑only behavior and teardown of test state, not real API deletes.
- Workers routing in v5 uses `script = <script_name>` on `cloudflare_workers_route`.

### Supplying variables (tests vs. example composition)

- Module tests: No external variables are required. Each test file (`modules/<module>/tests/*.tftest.hcl`) supplies its own `variables { ... }` block, and tests run at plan time without real API calls.
- Example composition (`examples/complete`): When you run `validate/plan/apply` for the example, you must provide the following variables:
  - `cloudflare_api_token` (string, sensitive)
  - `account_id` (string)
  - `zone_id` (string)
  - `domain` (string)

There are three common ways to pass these variables:

1) Using a `terraform.tfvars` file (recommended for local runs)

Place a file at `examples/complete/terraform.tfvars`:

```
cloudflare_api_token = "<YOUR_API_TOKEN>"
account_id           = "<YOUR_ACCOUNT_ID>"
zone_id              = "<YOUR_ZONE_ID>"
domain               = "example.com"
```

- Then run:
  - With mise: `mise run validate` and `mise run plan` (Terraform will auto‑load `terraform.tfvars` in that directory.)
  - Without mise:
    - `terraform -chdir=examples/complete init`
    - `terraform -chdir=examples/complete validate`
    - `terraform -chdir=examples/complete plan`

2) Using an explicit var‑file

```
terraform -chdir=examples/complete plan -var-file=terraform.tfvars
```

3) Using environment variables via the `TF_VAR_` convention

Export variables in your shell (only for the current process/session):

```
export TF_VAR_cloudflare_api_token="<YOUR_API_TOKEN>"
export TF_VAR_account_id="<YOUR_ACCOUNT_ID>"
export TF_VAR_zone_id="<YOUR_ZONE_ID>"
export TF_VAR_domain="example.com"

terraform -chdir=examples/complete plan
```

Notes:
- The example’s provider block uses `api_token = var.cloudflare_api_token` (see `examples/complete/provider.tf`), so the token must be provided as a Terraform variable (e.g., via `terraform.tfvars` or `TF_VAR_cloudflare_api_token`). Setting `CLOUDFLARE_API_TOKEN` alone is not sufficient unless you map it to the variable (e.g., `export TF_VAR_cloudflare_api_token="$CLOUDFLARE_API_TOKEN"`).
- Do not commit real tokens to version control. Prefer using a local, untracked `terraform.tfvars` or environment variables for secrets.

## Project Structure

```
modules/
  origin-ca/        # Origin CA certificate management module
  traffic-rules/    # Ruleset Engine traffic rules module
  workers/          # Cloudflare Workers deployment module
  zone-baseline/    # Baseline zone settings module
examples/complete/  # Example composition of modules (manual plan/apply)
mise.toml           # Pinned tools and local task shortcuts
```

Additional notable files:
- `examples/complete/worker-scripts/*.js` — sample Worker scripts used by the example composition.
- Each module includes `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`, and `tests/*.tftest.hcl`.

## Modules Overview
- `modules/zone-baseline`
  - Baseline Cloudflare zone settings using provider v5 resources (with `for_each` across settings where applicable).
- `modules/workers`
  - Creates a Worker script and optional routes; supports plaintext variable bindings; see module README for inputs/outputs and examples.
- `modules/traffic-rules`
  - Configures Ruleset Engine rules for traffic management.
- `modules/origin-ca`
  - Manages Origin CA certificates; provider requires a CSR when creating; tests assert defaults like `request_type` and `requested_validity`.

## Environment Variables
- `CLOUDFLARE_API_TOKEN` — required to run `apply` in the example composition. Not needed for module tests which are plan‑only.

## Example Usage
See `examples/complete` for a working composition. Provider configuration is in `examples/complete/provider.tf` and expects `CLOUDFLARE_API_TOKEN` in the environment.

Workers scripts referenced by the example live under `examples/complete/worker-scripts/`. When composing modules, pass script content via variables (e.g., `file("...")`).

## Development
Typical workflow:
1. `mise run fmt`
2. Edit module code in `modules/<module>`
3. Add/update `modules/<module>/tests/*.tftest.hcl` with plan‑time assertions
4. `terraform -chdir=modules/<module> init -backend=false -upgrade`
5. `terraform -chdir=modules/<module> test -verbose`
6. If modifying example composition, `mise run validate` and `mise run plan`

Version constraints:
- Root/example targets Terraform 1.14 syntax/features. Keep module `required_version` at `>= 1.5.0`, or bump consistently across modules if adopting newer language features.

## TODOs
- CI: Set up automated `terraform fmt`, `validate`, and module `test` in CI.
- Publishing: If these modules will be shared, add Terraform Registry metadata and examples as needed.
- Contribution Guide: Add `CONTRIBUTING.md` with code style and review process.

## License
MIT License — see [LICENSE](./LICENSE).

---
Attribution: If you use this POC or parts of the code in your own projects, a mention or link to this repository would be appreciated.
