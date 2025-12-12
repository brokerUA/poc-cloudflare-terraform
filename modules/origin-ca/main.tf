locals {
  should_generate_csr = var.csr == null
  is_ecc              = var.request_type == "origin-ecc"
}

# Generate a private key only when CSR is not provided
resource "tls_private_key" "ecc" {
  count       = local.should_generate_csr && local.is_ecc ? 1 : 0
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_private_key" "rsa" {
  count     = local.should_generate_csr && !local.is_ecc ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

locals {
  generated_private_key_pem = local.should_generate_csr ? coalesce(
    try(tls_private_key.ecc[0].private_key_pem, null),
    try(tls_private_key.rsa[0].private_key_pem, null)
  ) : null
}

# Create CSR when generating
resource "tls_cert_request" "generated" {
  count           = local.should_generate_csr ? 1 : 0
  private_key_pem = local.generated_private_key_pem

  subject {
    common_name = var.hostnames[0]
  }

  dns_names = var.hostnames
}

locals {
  csr_to_use = local.should_generate_csr ? tls_cert_request.generated[0].cert_request_pem : var.csr
}

resource "cloudflare_origin_ca_certificate" "this" {
  request_type       = var.request_type
  hostnames          = var.hostnames
  requested_validity = var.requested_validity
  csr                = local.csr_to_use
}
