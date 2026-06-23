# Wrapper for module: `modules/iam-role`

The configuration in this directory contains an implementation of a single module wrapper pattern, which allows managing several copies of a module in places where using the native Terraform 0.13+ `for_each` feature is not feasible (e.g., with Terragrunt).

You may want to use a single Terragrunt configuration file to manage multiple resources without duplicating `terragrunt.hcl` files for each copy of the same module.

This wrapper does not implement any extra functionality.

## Usage with Terragrunt

`terragrunt.hcl`:

```hcl
terraform {
  source = "${get_repo_root()}//wrappers/iam-role"
  # Alternative source:
  # source = "git::git@github.com:datafy-io/terraform-datafy-iam-role.git//wrappers/iam-role?ref=main"
}

inputs = {
  defaults = { # Default values
    permissions_level = "AutoScaler"
    permissions_scope = "Global"
    oidc_url          = "https://oidc.datafy.io"
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Service     = "datafy"
    }
  }

  items = {
    my-item = {
      account_id = "123e4567-e89b-12d3-a456-426614174000"
      role_name  = "DatafyPrimaryRole"
    }
    my-second-item = {
      account_id        = "123e4567-e89b-12d3-a456-426614174001"
      role_name         = "DatafyRegionalRole"
      permissions_scope = "Regional"
      regions           = ["us-east-1", "us-west-2"]
    }
    # omitted... can be any argument supported by the module
  }
}
```

## Usage with Terraform

```hcl
module "wrapper" {
  source = "../../wrappers/iam-role"

  defaults = { # Default values
    permissions_level = "AutoScaler"
    permissions_scope = "Global"
    oidc_url          = "https://oidc.datafy.io"
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Service     = "datafy"
    }
  }

  items = {
    my-item = {
      account_id = "123e4567-e89b-12d3-a456-426614174000"
      role_name  = "DatafyPrimaryRole"
    }
    my-second-item = {
      account_id        = "123e4567-e89b-12d3-a456-426614174001"
      role_name         = "DatafyRegionalRole"
      permissions_scope = "Regional"
      regions           = ["us-east-1", "us-west-2"]
    }
    # omitted... can be any argument supported by the module
  }
}
```

## Example: Manage multiple Datafy IAM roles in one Terragrunt layer

`live/prod/datafy-iam-roles/terragrunt.hcl`:

```hcl
terraform {
  source = "${get_repo_root()}//wrappers/iam-role"
  # Alternative source:
  # source = "git::git@github.com:datafy-io/terraform-datafy-iam-role.git//wrappers/iam-role?ref=main"
}

inputs = {
  defaults = {
    permissions_level = "AutoScaler"
    permissions_scope = "Global"
    oidc_url          = "https://oidc.datafy.io"
    tags = {
      Environment = "prod"
      ManagedBy   = "terragrunt"
    }
  }

  items = {
    role1 = {
      account_id = "123e4567-e89b-12d3-a456-426614174010"
      role_name  = "DatafyAutoScalerRole"
    }
    role2 = {
      account_id        = "123e4567-e89b-12d3-a456-426614174011"
      role_name         = "DatafySensorUsRole"
      permissions_level = "Sensor"
      permissions_scope = "Regional"
      regions           = ["us-east-1", "us-west-2"]
      tags = {
        Secure = "probably"
      }
    }
  }
}
```
