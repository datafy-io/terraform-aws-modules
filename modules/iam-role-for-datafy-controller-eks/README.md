# IAM role for Datafy controller on EKS

It intentionally exposes only these inputs:

- `name`
- `cluster_name`
- `namespace`
- `service_account`

It creates the IRSA trust relationship for the specified Kubernetes
service account.

The module resolves the OIDC provider from `cluster_name`.

## Usage

```hcl
module "irsa" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  name            = "eks-my-app-role"
  cluster_name    = "my-eks-cluster"
  namespace       = "default"
  service_account = "my-app-sa"
}
```
