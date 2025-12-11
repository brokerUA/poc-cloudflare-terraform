# output "worker_maintenance_route_id" {
#   value       = module.worker_maintenance.worker_route_id
#   description = "Worker maintenance route ID"
# }

# output "image_variant_ids" {
#   value       = module.media_transformations.variant_ids
#   description = "Created image variant IDs"
# }

output "origin_ca_certificate_id" {
  value       = module.origin_ca.id
  description = "Origin CA certificate ID"
}

output "origin_ca_certificate_expires_on" {
  value       = module.origin_ca.expires_on
  description = "When the Origin CA certificate expires"
}

output "origin_ca_certificate_pem" {
  value       = module.origin_ca.certificate
  description = "PEM-encoded Origin CA certificate"
  sensitive   = true
}
