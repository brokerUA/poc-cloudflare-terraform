// Unit tests for origin-ca module

run "plan_default_ecc" {
  command = plan

  variables {
    account_id = "acc_123"
    hostnames  = ["example.com", "*.example.com"]
    // Provider v5 requires a CSR to be provided explicitly.
    // Use a minimal dummy CSR while still validating defaults.
    csr = <<-EOT
-----BEGIN CERTIFICATE REQUEST-----
MIIBWTCB/AAwEjEQMA4GA1UEAwwHZGVmYXVs dAIBADAeFw0yNTAxMDEwMDAwMDBa
Fw0yNjAxMDEwMDAwMDBaMBIxEDAOBgNVBAMMB2V4YW1wbGUwWTATBgcqhkjOPQIB
BggqhkjOPQMBBwNCAAQ8h0e9d2Xr1y8m6uZgZ7kE1Yg3O2mJ0Kc4xw8CwqM6z8o0
f7e1gkq0zJqZ0j6X3zVJtH2c2t3zF8YxU0Z8o7hpoAAwCgYIKoZIzj0EAwIDSQAw
RgIhAO3yqYlP9c3c8Pzq8ZKk3B+f9sQy1hQ1QJv7b8uJQP8NAiEApXoKp2yq5w2v
z+4h5v4YkqM6JmYQ7rVbX2i4m8i5J3I=
-----END CERTIFICATE REQUEST-----
EOT
    // defaults: request_type = "origin-ecc", requested_validity = 5475
  }

  assert {
    condition     = resource.cloudflare_origin_ca_certificate.this.request_type == "origin-ecc"
    error_message = "default request_type must be origin-ecc"
  }

  assert {
    condition     = resource.cloudflare_origin_ca_certificate.this.hostnames[0] == "example.com" && resource.cloudflare_origin_ca_certificate.this.hostnames[1] == "*.example.com"
    error_message = "hostnames should be wired into the resource"
  }

  assert {
    condition     = resource.cloudflare_origin_ca_certificate.this.requested_validity == 5475
    error_message = "requested_validity default should be 5475 days"
  }
}

run "plan_with_csr_and_rsa" {
  command = plan

  variables {
    account_id         = "acc_456"
    hostnames          = ["api.example.com"]
    request_type       = "origin-rsa"
    // Provider allows only specific validity values; choose 365 (1 year)
    requested_validity = 365
    csr                = <<-EOT
-----BEGIN CERTIFICATE REQUEST-----
MIIBWTCB/AAwEjEQMA4GA1UEAwwHYXBpLmxvYwIBADAeFw0yNTAxMDEwMDAwMDBa
Fw0yNjAxMDEwMDAwMDBaMBoxGDAWBgNVBAMMD2FwaS5leGFtcGxlLmNvbTBZMBMG
ByqGSM49AgEGCCqGSM49AwEHA0IABJ7R1ZQm3J9mC7+g7oR0Yk0y5k3h1U6y0Wv5
fC8xYI1b5lq2QdQ0m7h2mQ1mXz0Pfa8nV3v1m5b8U0W8n0JbB2igADAKBggqhkjO
PQQDAgNIADBFAiEA0U0g0m0R1kQ7bq8WmV3kQ0y0k1f7vY8yVf4oR2ZtV5ACIC6O
oJ4p3r0m1q2w5b4l6k7m8n9o0p1q2r3s4t5u6v7w
-----END CERTIFICATE REQUEST-----
EOT
  }

  assert {
    condition     = resource.cloudflare_origin_ca_certificate.this.request_type == "origin-rsa"
    error_message = "request_type should reflect the provided value origin-rsa"
  }

  assert {
    condition     = resource.cloudflare_origin_ca_certificate.this.csr != null
    error_message = "csr must be forwarded to the resource when provided"
  }

  assert {
    condition     = resource.cloudflare_origin_ca_certificate.this.requested_validity == 365
    error_message = "requested_validity should reflect provided value"
  }
}
