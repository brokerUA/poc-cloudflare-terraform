// Unit tests for zone-baseline module
// Goal: ensure that enabling image_resizing = "on" is reflected in the planned
// Cloudflare zone settings override resource.

run "plan_with_image_resizing_on" {
  command = plan

  variables {
    zone_id = "dummy-zone-id"

    settings = {
      ssl             = "strict"
      min_tls_version = "1.2"
      brotli          = "on"
      image_resizing  = "on"
    }

    dns_records = []
  }

  // Assert: per-setting resource for image_resizing exists and is set to "on".
  assert {
    condition     = resource.cloudflare_zone_setting.settings["image_resizing"].value == "on"
    error_message = "Expected image_resizing to be 'on' via cloudflare_zone_setting resource."
  }
}
