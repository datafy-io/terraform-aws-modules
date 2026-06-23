variable "name" {
  type        = string
  description = "IAM role name to create for the Kubernetes service account."

  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "Name of the EKS cluster."

  validation {
    condition     = var.cluster_name == null || length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty when provided."
  }
}

variable "oidc_provider_arn" {
  type        = string
  default     = null
  description = "ARN of an existing IAM OIDC provider for the EKS cluster."

  validation {
    condition     = var.oidc_provider_arn == null || length(var.oidc_provider_arn) > 0
    error_message = "oidc_provider_arn must not be empty when provided."
  }

  validation {
    condition     = var.oidc_provider_arn == null || can(regex(":oidc-provider/.+", var.oidc_provider_arn))
    error_message = "oidc_provider_arn must be a valid IAM OIDC provider ARN."
  }
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for the service account."

  validation {
    condition     = length(var.namespace) > 0
    error_message = "namespace must not be empty."
  }
}

variable "service_account" {
  type        = string
  description = "Kubernetes service account name."
  default     = "datafy-controller-sa"

  validation {
    condition     = length(var.service_account) > 0
    error_message = "service_account must not be empty."
  }
}

variable "permissions" {
  description = "Inline IAM policy statements to attach to the role."
  type = list(object({
    actions   = list(string)
    resources = list(string)
    effect    = optional(string, "Allow")
  }))
  default = []
}
