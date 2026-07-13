# IAM role for Datafy controller on EKS

It intentionally exposes only these inputs:

- `role_name`
- `cluster_name`
- `datafy_controller_namespace`
- `datafy_controller_service_account_name`

It creates the IRSA trust relationship for the specified Kubernetes
service account.

The module resolves the OIDC provider from `cluster_name`.

## Usage

```hcl
module "irsa" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  role_name                              = "eks-my-app-role"
  cluster_name                           = "my-eks-cluster"
  datafy_controller_namespace            = "default"
  datafy_controller_service_account_name = "my-app-sa"
}
```
