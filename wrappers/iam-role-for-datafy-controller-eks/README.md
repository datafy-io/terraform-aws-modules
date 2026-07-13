# Wrapper for module: `modules/iam-role-for-datafy-controller-eks`

The configuration in this directory contains an implementation of a single module wrapper pattern, which allows managing several copies of a module in places where using the native Terraform 0.13+ `for_each` feature is not feasible (e.g., with Terragrunt).

You may want to use a single Terragrunt configuration file to manage multiple Datafy controller IRSA roles without duplicating `terragrunt.hcl` files for each copy of the same module.

This wrapper does not implement any extra functionality.

## Usage with Terragrunt

`terragrunt.hcl`:

```hcl
terraform {
  source = "${get_repo_root()}//wrappers/iam-role-for-datafy-controller-eks"
}

inputs = {
  defaults = {
    datafy_controller_namespace            = "default"
    datafy_controller_service_account_name = "datafy-controller-sa"
  }

  items = {
    controller = {
      role_name    = "datafy-irsa-cluster"
      cluster_name = "my-eks-cluster"
    }
    another = {
      role_name    = "datafy-irsa-other"
      cluster_name = "my-other-eks-cluster"
    }
  }
}
```

## Usage with Terraform

```hcl
module "wrapper" {
  source = "../../wrappers/iam-role-for-datafy-controller-eks"

  defaults = {
    datafy_controller_namespace            = "default"
    datafy_controller_service_account_name = "datafy-controller-sa"
  }

  items = {
    controller = {
      role_name    = "datafy-irsa-cluster"
      cluster_name = "my-eks-cluster"
    }
    another = {
      role_name    = "datafy-irsa-other"
      cluster_name = "my-other-eks-cluster"
    }
  }
}
```
