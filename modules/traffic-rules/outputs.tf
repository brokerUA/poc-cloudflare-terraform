output "cache_ruleset_id" {
  description = "ID of the cache ruleset (if created)."
  value       = try(cloudflare_ruleset.cache[0].id, null)
}

output "redirect_ruleset_id" {
  description = "ID of the redirect ruleset (if created)."
  value       = try(cloudflare_ruleset.redirect[0].id, null)
}

output "rewrite_ruleset_id" {
  description = "ID of the URL rewrite ruleset (if created)."
  value       = try(cloudflare_ruleset.rewrite[0].id, null)
}
