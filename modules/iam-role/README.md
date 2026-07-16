# Datafy IAM Role module

Creates a Datafy IAM role, an IAM OIDC provider, and inline policies for
global or regional operation modes.

## Usage

```hcl
module "datafy_iam_role" {
  source = "../../modules/iam-role"

  account_id        = "123e4567-e89b-12d3-a456-426614174000"
  permissions_level = "AutoScaler"
  permissions_scope = "Global"
}
```

`account_id` is optional. Provide your Datafy Account ID or Organization ID o scope the assume-role subject to `datafy.io/<account_id>`;
leave it empty to use `datafy.io`.

## Outputs

- `role_arn`
- `role_name`
- `oidc_provider_arn`
