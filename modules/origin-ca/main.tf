resource "cloudflare_origin_ca_certificate" "this" {
  request_type       = var.request_type
  hostnames          = var.hostnames
  requested_validity = var.requested_validity

  # If CSR is provided, CF will not return a private key.
  # If CSR is null, CF generates keypair and returns private_key.
  csr = var.csr
}
