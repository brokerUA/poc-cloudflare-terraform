variable "zone_id" {
  description = "Cloudflare Zone ID to manage."
  type        = string
}

variable "settings" {
  description = "Map of Cloudflare zone settings to apply using per-setting resources. Values can be string, number, bool, list, or object depending on the setting. Special case: set key 'ssl_recommender' to a boolean and it will be applied via the 'enabled' attribute."
  type        = map(any)
  default     = {}
}

variable "dns_records" {
  description = "List of DNS records to create in the zone. Optional fields can be null."
  type = list(object({
    name     = string
    type     = string
    content  = string
    ttl      = optional(number)
    proxied  = optional(bool)
    priority = optional(number)
    comment  = optional(string)
    tags     = optional(list(string))
  }))
  default = []
}
