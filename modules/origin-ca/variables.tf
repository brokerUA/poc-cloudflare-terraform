variable "account_id" {
  description = "Cloudflare Account ID."
  type        = string
}

variable "hostnames" {
  description = "List of hostnames to be included in the Origin CA certificate (e.g., example.com, *.example.com)."
  type        = list(string)
}

variable "request_type" {
  description = "Origin CA request type specifying key algorithm. One of: origin-ecc, origin-rsa."
  type        = string
  default     = "origin-ecc"

  validation {
    condition     = contains(["origin-ecc", "origin-rsa"], var.request_type)
    error_message = "request_type must be one of: origin-ecc, origin-rsa."
  }
}

variable "requested_validity" {
  description = "Requested certificate validity in days (e.g., 5475 = 15 years)."
  type        = number
  default     = 5475
}

variable "csr" {
  description = "Optional PEM-encoded CSR. If omitted, Cloudflare will generate a private key and return it."
  type        = string
  default     = null
  sensitive   = true
}
