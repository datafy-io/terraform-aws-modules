module "wrapper" {
  source   = "../../modules/iam-role-for-datafy-controller-eks"
  for_each = var.items

  role_name                              = try(each.value.role_name, var.defaults.role_name)
  cluster_name                           = try(each.value.cluster_name, var.defaults.cluster_name)
  datafy_controller_namespace            = try(each.value.datafy_controller_namespace, var.defaults.datafy_controller_namespace)
  datafy_controller_service_account_name = try(each.value.datafy_controller_service_account_name, var.defaults.datafy_controller_service_account_name, "datafy-controller-sa")
}
