variable "defaults" {
  type        = any
  description = "Default values applied to each item."
  default     = {}
}

variable "items" {
  type        = any
  description = "Map of items to create with the wrapped module."
  default     = {}
}
