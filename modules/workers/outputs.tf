output "worker_script_name" {
  description = "Name of the deployed Worker script."
  value       = cloudflare_workers_script.this.script_name
}

output "worker_route_ids" {
  description = "Map of Worker route IDs keyed by route pattern. Empty if no routes created."
  value       = { for k, r in cloudflare_workers_route.this : k => r.id }
}

output "worker_route_id" {
  description = "Backward-compatible single Worker route ID (first if multiple, null if none)."
  value       = length(cloudflare_workers_route.this) > 0 ? values(cloudflare_workers_route.this)[0].id : null
}
