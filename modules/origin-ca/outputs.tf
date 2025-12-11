output "certificate" {
  description = "PEM-encoded Origin CA certificate."
  value       = cloudflare_origin_ca_certificate.this.certificate
}

output "csr" {
  description = "CSR used for the request (input)."
  value       = var.csr
  sensitive   = true
}

output "expires_on" {
  description = "Certificate expiration timestamp."
  value       = try(cloudflare_origin_ca_certificate.this.expires_on, null)
}

output "id" {
  description = "Origin CA certificate ID."
  value       = cloudflare_origin_ca_certificate.this.id
}

output "hostnames" {
  description = "Hostnames included in the certificate."
  value       = var.hostnames
}

output "request_type" {
  description = "Origin CA request type (origin-ecc or origin-rsa)."
  value       = var.request_type
}

## Note: Root CA certificate and generated private key can be obtained outside of Terraform if needed.
