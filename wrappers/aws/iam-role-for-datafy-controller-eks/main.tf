module "wrapper" {
  source   = "../../../aws/iam-role-for-datafy-controller-eks"
  for_each = var.items

  name            = try(each.value.name, var.defaults.name)
  cluster_name    = try(each.value.cluster_name, var.defaults.cluster_name)
  namespace       = try(each.value.namespace, var.defaults.namespace)
  service_account = try(each.value.service_account, var.defaults.service_account, "datafy-controller-sa")
}
