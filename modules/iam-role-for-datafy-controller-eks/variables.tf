variable "role_name" {
  type        = string
  description = "IAM role name to create for the Kubernetes service account."

  validation {
    condition     = length(var.role_name) > 0
    error_message = "role_name must not be empty."
  }
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster."

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "datafy_controller_namespace" {
  type        = string
  description = "Kubernetes namespace for the service account."

  validation {
    condition     = length(var.datafy_controller_namespace) > 0
    error_message = "datafy_controller_namespace must not be empty."
  }
}

variable "datafy_controller_service_account_name" {
  type        = string
  description = "Kubernetes service account name."
  default     = "datafy-controller-sa"

  validation {
    condition     = length(var.datafy_controller_service_account_name) > 0
    error_message = "datafy_controller_service_account_name must not be empty."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to created resources."
  default     = {}
}