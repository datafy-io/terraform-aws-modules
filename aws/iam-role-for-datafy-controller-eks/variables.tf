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
  description = "Name of the EKS cluster."

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
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
