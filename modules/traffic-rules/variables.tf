variable "zone_id" {
  description = "Cloudflare Zone ID where the rulesets will be applied."
  type        = string
}

variable "cache_rules" {
  description = "List of cache rules for phase http_request_cache_settings."
  type = list(object({
    description = optional(string, "cache rule")
    expression  = string
    enabled     = optional(bool, true)
    # Basic action parameters for cache settings
    cache = optional(object({
      ttl                 = optional(number) # seconds
      cache_by_device     = optional(bool)
      respect_strong_etag = optional(bool)
    }), null)
  }))
  default = []
}

variable "redirect_rules" {
  description = "List of redirect rules for phase http_request_redirect."
  type = list(object({
    description           = optional(string, "redirect rule")
    expression            = string
    enabled               = optional(bool, true)
    status_code           = optional(number, 301)
    destination           = string
    preserve_query_string = optional(bool, true)
  }))
  default = []
}

variable "url_rewrite_rules" {
  description = "List of URL rewrite rules for phase http_request_dynamic_redirect or http_url_rewrite."
  type = list(object({
    description = optional(string, "rewrite rule")
    expression  = string
    enabled     = optional(bool, true)
    to          = string # Target path or URL
  }))
  default = []
}
