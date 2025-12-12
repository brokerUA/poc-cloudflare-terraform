# origin-ca module

Issue Cloudflare Origin CA certificates for one or more hostnames (for example, `example.com` and `*.example.com`). Use this certificate to encrypt traffic between Cloudflare and your origin server.

## Prerequisites
- Terraform `>= 1.5.0` and the Cloudflare provider `>= 5.0.0` (the module declares these in `versions.tf`).
- A Cloudflare API token with Account scope permissions to issue Origin CA certificates.
  - At minimum, the token should allow creating Origin CA certificates in the target account.
- Optional but recommended: install the Cloudflare Origin CA root certificate on your origin server so that your origin trusts the certificate chain presented by Cloudflare.

Example provider configuration:

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

## Inputs
- `hostnames` (list(string), required)
  - Hostnames to include in the certificate (e.g., `["example.com", "*.example.com"]`).
- `request_type` (string, optional, default: `"origin-ecc"`)
  - Key algorithm for the Origin CA certificate. One of: `origin-ecc`, `origin-rsa`.
- `requested_validity` (number, optional, default: `5475`)
  - Requested certificate validity in days (e.g., `5475` = 15 years).
- `csr` (string, optional, default: `null`, sensitive)
  - PEM-encoded CSR. If omitted, Cloudflare generates a keypair and returns the private key together with the certificate. When a CSR is provided, Cloudflare will not return a private key.

## Outputs
- `certificate`
  - PEM-encoded Origin CA certificate.
- `csr` (sensitive)
  - CSR used for the request (passes through the input value).
- `expires_on`
  - Certificate expiration timestamp.
- `id`
  - Origin CA certificate ID in Cloudflare.
- `hostnames`
  - Hostnames included in the certificate.
- `request_type`
  - Final request type (`origin-ecc` or `origin-rsa`).

## Minimal example

```hcl
variable "cloudflare_api_token" { type = string }

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "origin_ca" {
  source             = "../origin-ca"
  hostnames          = ["example.com", "*.example.com"]
  # request_type     = "origin-ecc"   # optional
  # requested_validity = 5475          # optional
  # csr              = null            # optional
}

output "origin_cert" {
  value = module.origin_ca.certificate
}
```

Notes
- Handle any returned private key and the `csr` output securely. Marking values as `sensitive` prevents them from being printed in logs and CLI output, but you should still store and transmit them securely.
