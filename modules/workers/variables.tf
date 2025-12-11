variable "account_id" {
  description = "Cloudflare Account ID where the Worker script will be deployed."
  type        = string
}

variable "zone_id" {
  description = "Cloudflare Zone ID where the Worker route will be applied."
  type        = string
}

variable "script_name" {
  description = "Name of the Worker script."
  type        = string
}

variable "script_content" {
  description = "Inline Worker script content."
  type        = string
}

variable "route_pattern" {
  description = "DEPRECATED: Single route pattern to attach the Worker, e.g., example.com/* — use route_patterns instead."
  type        = string
  default     = null
}

variable "plain_text_vars" {
  description = "Map of plaintext environment variables to bind to the Worker script (name => value)."
  type        = map(string)
  default     = {}
}

variable "route_patterns" {
  description = "List of route patterns to attach the Worker, e.g., [\"example.com/*\", \"www.example.com/*\"]"
  type        = list(string)
  default     = []
}

variable "create_route" {
  description = "Whether to create Worker routes. If false, only the script will be created."
  type        = bool
  default     = true
}

variable "main_module" {
  description = "Path to the Worker script's main module."
  type        = string
  default     = "index.js"
}