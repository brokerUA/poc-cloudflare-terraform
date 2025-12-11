variable "cloudflare_api_token" {
  description = "API token with necessary permissions for managing the target zone and account."
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Target Cloudflare Zone ID."
  type        = string
}

variable "account_id" {
  description = "Cloudflare Account ID."
  type        = string
}

variable "domain" {
  description = "Target domain name."
  type        = string
}