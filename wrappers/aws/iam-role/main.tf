module "wrapper" {
  source   = "../../../aws/iam-role"
  for_each = var.items

  account_id        = try(each.value.account_id, var.defaults.account_id)
  role_name         = try(each.value.role_name, var.defaults.role_name, "DatafyIORole")
  oidc_url          = try(each.value.oidc_url, var.defaults.oidc_url, "https://oidc.datafy.io")
  permissions_level = try(each.value.permissions_level, var.defaults.permissions_level, "AutoScaler")
  permissions_scope = try(each.value.permissions_scope, var.defaults.permissions_scope, "Global")
  regions           = try(each.value.regions, var.defaults.regions, [])
  tags              = try(each.value.tags, var.defaults.tags, {})
}
