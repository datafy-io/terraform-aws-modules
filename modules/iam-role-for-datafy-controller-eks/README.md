# IAM role for Datafy controller on EKS

It intentionally exposes only these inputs:

- `name`
- `cluster_name`
- `oidc_provider_arn`
- `namespace`
- `service_account`
- `permissions`

It creates the IRSA trust relationship for the specified Kubernetes
service account and can optionally attach inline permissions to the
role.

Provide either `cluster_name` or `oidc_provider_arn`.

If both are provided, the module resolves the OIDC provider from
`cluster_name` and verifies that it matches the supplied
`oidc_provider_arn`.

See [examples/iam-role-for-datafy-controller-eks](../../examples/iam-role-for-datafy-controller-eks) for all supported input combinations.

## Usage

```hcl
module "irsa" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  name            = "eks-my-app-role"
  cluster_name    = "my-eks-cluster"
  namespace       = "default"
  service_account = "my-app-sa"
  permissions = [
    {
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::my-bucket/*"]
    }
  ]
}
```

Alternative usage when you already know the OIDC provider ARN:

```hcl
module "irsa" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  name              = "eks-my-app-role"
  oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
  namespace         = "default"
  service_account   = "my-app-sa"
}
```
