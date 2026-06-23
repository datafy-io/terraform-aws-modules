module "wrapper" {
  source   = "../../modules/iam-role-for-datafy-controller-eks"
  for_each = var.items

  name              = try(each.value.name, var.defaults.name)
  cluster_name      = try(each.value.cluster_name, var.defaults.cluster_name, null)
  oidc_provider_arn = try(each.value.oidc_provider_arn, var.defaults.oidc_provider_arn, null)
  namespace         = try(each.value.namespace, var.defaults.namespace)
  service_account   = try(each.value.service_account, var.defaults.service_account, "datafy-controller-sa")
  permissions       = try(each.value.permissions, var.defaults.permissions, [])
}
