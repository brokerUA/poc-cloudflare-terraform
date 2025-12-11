output "dns_record_ids" {
  description = "Map of DNS record resource IDs keyed by synthetic key."
  value       = { for k, r in cloudflare_dns_record.this : k => r.id }
}
