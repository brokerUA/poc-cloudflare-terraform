// Unit tests for origin-ca module

run "plan_default_ecc" {
  command = plan

  variables {
    hostnames = ["example.com", "*.example.com"]
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

  assert {
    condition     = output.generated == true
    error_message = "module should generate CSR when none is provided"
  }

  // Ensure TLS resources are planned and wired
  assert {
    condition     = resource.tls_private_key.ecc[0].algorithm == "ECDSA"
    error_message = "ECC private key should be generated when request_type is origin-ecc"
  }

  assert {
    condition     = resource.tls_cert_request.generated[0].dns_names[0] == "example.com" && resource.tls_cert_request.generated[0].dns_names[1] == "*.example.com"
    error_message = "Generated CSR should include provided hostnames"
  }
}

run "plan_with_csr_and_rsa" {
  command = plan

  variables {
    hostnames    = ["api.example.com"]
    request_type = "origin-rsa"
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
    condition     = resource.cloudflare_origin_ca_certificate.this.requested_validity == 365
    error_message = "requested_validity should reflect provided value"
  }

  assert {
    condition     = output.generated == false
    error_message = "module should not generate CSR when input csr is provided"
  }
}
