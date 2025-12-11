// Unit tests for workers module
// Verifies that the workers route is created with the expected pattern.

run "plan_workers_route_single" {
  command = plan

  variables {
    account_id    = "acc_12345"
    zone_id       = "zone_12345"
    script_name   = "test-worker"
    route_pattern = "example.com/test/*"
    // Mock script content to avoid file reads
    script_content = "export default { async fetch() { return new Response('ok'); } }"
  }

  assert {
    condition     = resource.cloudflare_workers_route.this["example.com/test/*"].pattern == "example.com/test/*"
    error_message = "Expected workers route pattern to match the provided variable."
  }
}

run "plan_workers_multiple_routes" {
  command = plan

  variables {
    account_id  = "acc_12345"
    zone_id     = "zone_12345"
    script_name = "test-worker"
    route_patterns = [
      "example.com/a/*",
      "www.example.com/b/*"
    ]
    script_content = "export default { async fetch() { return new Response('ok'); } }"
  }

  assert {
    condition     = resource.cloudflare_workers_route.this["example.com/a/*"].pattern == "example.com/a/*"
    error_message = "Expected first workers route to be created with its pattern."
  }

  assert {
    condition     = resource.cloudflare_workers_route.this["www.example.com/b/*"].pattern == "www.example.com/b/*"
    error_message = "Expected second workers route to be created with its pattern."
  }
}

run "plan_workers_no_routes_when_disabled" {
  command = plan

  variables {
    account_id     = "acc_12345"
    zone_id        = "zone_12345"
    script_name    = "test-worker"
    route_patterns = ["example.com/*"]
    create_route   = false
    script_content = "export default { async fetch() { return new Response('ok'); } }"
  }

  assert {
    condition     = length(resource.cloudflare_workers_route.this) == 0
    error_message = "Expected no routes to be created when create_route is false."
  }
}
