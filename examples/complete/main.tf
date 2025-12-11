module "zone_baseline" {
  source  = "../../modules/zone-baseline"
  zone_id = var.zone_id

  settings = {
    ssl             = "strict"
    min_tls_version = "1.3"
    brotli          = "on"
  }

  dns_records = [
    {
      name    = "@"
      type    = "A"
      content = "192.0.2.1"
      proxied = true
    },
    {
      name    = "www"
      type    = "A"
      content = "192.0.2.1"
      proxied = true
    }
  ]
}

# Generic Worker: maintenance-page
module "worker_maintenance" {
  source         = "../../modules/workers"
  account_id     = var.account_id
  zone_id        = var.zone_id
  script_name    = "maintenance-page"
  route_patterns = ["https://${var.domain}/*", "https://*.${var.domain}/*"]
  create_route   = false

  script_content = file("${path.module}/worker-scripts/maintenance.js")
}

# Generic Worker: image-transformer (placeholder)
module "worker_image_transformer" {
  source         = "../../modules/workers"
  account_id     = var.account_id
  zone_id        = var.zone_id
  script_name    = "image-transformer"
  route_patterns = ["https://${var.domain}/media/*", "https://sources.${var.domain}/images/*"]

  script_content = file("${path.module}/worker-scripts/image-transformer.js")

  plain_text_vars = {
    ALLOWED_HOSTS  = "${var.domain},sources.${var.domain}"
    ALLOWED_WIDTHS = "128,256,640,1080"
    IMAGE_QUALITY  = "80"
  }
}

# Traffic Rules: redirect, cache, rewrite
module "traffic_rules" {
  source  = "../../modules/traffic-rules"
  zone_id = var.zone_id

  # 1) Redirect rule: /old to https://<domain>/new (301)
  redirect_rules = [
    {
      description = "Redirect /old to /new"
      # Match exactly path /old on the apex or www host
      expression            = "(http.host eq \"${var.domain}\" or http.host eq \"www.${var.domain}\") and http.request.uri.path eq \"/old\""
      status_code           = 301
      destination           = "https://${var.domain}/new"
      preserve_query_string = true
      enabled               = false
    }
  ]

  # 2) Cache rule: cache images under /media/ for 1 hour, respect strong ETag
  cache_rules = [
    {
      description = "Cache media images for 1 hour"
      expression  = "http.host eq \"${var.domain}\" and starts_with(http.request.uri.path, \"/media/\")"
      cache = {
        ttl                 = 3600
        respect_strong_etag = true
      }
    }
  ]

  # 3) Rewrite rule: rewrite /blog to /news (path only)
  url_rewrite_rules = [
    {
      description = "Rewrite /blog to /news"
      expression  = "http.host eq \"${var.domain}\" and http.request.uri.path eq \"/blog\""
      to          = "/news"
    }
  ]
}

# Origin CA certificate for apex and wildcard hosts
module "origin_ca" {
  source     = "../../modules/origin-ca"
  account_id = var.account_id

  hostnames = [
    var.domain,
    "*.${var.domain}"
  ]

  # Defaults to ECC and 15 years; override as needed
  # request_type       = "origin-ecc"
  # requested_validity = 5475
  # csr = null
}
