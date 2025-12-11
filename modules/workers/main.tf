resource "cloudflare_workers_script" "this" {
  account_id  = var.account_id
  script_name = var.script_name
  content     = var.script_content
  main_module = var.main_module

  bindings = [
    for k, v in var.plain_text_vars : {
      type = "plain_text"
      name = k
      text = v
    }
  ]
}

locals {
  effective_patterns = length(var.route_patterns) > 0 ? var.route_patterns : (
    var.route_pattern != null && trimspace(var.route_pattern) != "" ? [var.route_pattern] : []
  )
}

resource "cloudflare_workers_route" "this" {
  for_each = var.create_route ? { for p in local.effective_patterns : p => p } : {}

  zone_id = var.zone_id
  pattern = each.key
  # In provider v5, the argument is "script" specifying the bound script name
  script = var.script_name

  depends_on = [
    cloudflare_workers_script.this
  ]
}
