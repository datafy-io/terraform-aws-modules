variable "permissions_level" {
  type        = string
  default     = "AutoScaler"
  description = "Defines the level of permissions for the role."

  validation {
    condition     = contains(["Sensor", "AutoScaler"], var.permissions_level)
    error_message = "Invalid value for permissions_level. Allowed values are 'Sensor' or 'AutoScaler'."
  }
}

variable "permissions_scope" {
  type        = string
  default     = "Global"
  description = "Use 'Global' for all regions or 'Regional' to limit permissions to the values in `regions`."

  validation {
    condition     = contains(["Regional", "Global"], var.permissions_scope)
    error_message = "Invalid value for permissions_scope. Allowed values are 'Regional' or 'Global'."
  }
}

variable "regions" {
  type        = list(string)
  default     = []
  description = "List of AWS regions used when `permissions_scope` is `Regional`."

  validation {
    condition     = var.permissions_scope == "Global" ? length(var.regions) == 0 : length(var.regions) > 0
    error_message = "Regions must be empty for Global scope and non-empty for Regional scope."
  }

  validation {
    condition = var.permissions_scope == "Global" || alltrue([
      for r in var.regions : contains([
        "af-south-1",
        "ap-east-1",
        "ap-northeast-1",
        "ap-northeast-2",
        "ap-northeast-3",
        "ap-south-1",
        "ap-south-2",
        "ap-southeast-1",
        "ap-southeast-2",
        "ap-southeast-3",
        "ca-central-1",
        "cn-north-1",
        "cn-northwest-1",
        "es-central-1",
        "eu-central-1",
        "eu-central-2",
        "eu-north-1",
        "eu-south-1",
        "eu-south-2",
        "eu-west-1",
        "eu-west-2",
        "eu-west-3",
        "il-central-1",
        "me-central-1",
        "me-south-1",
        "mx-central-1",
        "sa-east-1",
        "us-east-1",
        "us-east-2",
        "us-gov-east-1",
        "us-gov-west-1",
        "us-west-1",
        "us-west-2"
      ], r)
    ])
    error_message = "Invalid value for regions."
  }
}

variable "account_id" {
  type        = string
  description = "Your Datafy Account ID or Organization ID (Optional)."

  validation {
    condition     = length(trimspace(var.account_id)) == 0 || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.account_id))
    error_message = "Account ID must be a valid UUID (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)."
  }
}

variable "role_name" {
  type        = string
  description = "Name of the IAM role to create."
  default     = "DatafyIORole"

  validation {
    condition     = length(var.role_name) > 0
    error_message = "Role name cannot be empty."
  }
}

variable "oidc_url" {
  type        = string
  description = "OIDC URL used by the IAM role."
  default     = "https://oidc.datafy.io"

  validation {
    condition     = can(regex("https://[a-zA-Z0-9.-]+", var.oidc_url))
    error_message = "Invalid OIDC URL format."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to created resources."
  default     = {}
}
