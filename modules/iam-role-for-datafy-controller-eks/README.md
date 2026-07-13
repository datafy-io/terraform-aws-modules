# IAM role for Datafy controller on EKS

It creates the IRSA trust relationship for the specified Kubernetes service account.
The module resolves the OIDC provider from `cluster_name`.

## Usage

```hcl
module "irsa" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  cluster_name                           = "my-eks-cluster"
  datafy_controller_namespace            = "datafy"
  datafy_controller_service_account_name = "datafy-controller-sa"
}
```
