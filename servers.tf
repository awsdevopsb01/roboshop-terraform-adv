module "database_servers" {
  for_each = var.database_servers
  source = "./module"
  component_name = each.value["name"]
  instance_type = each.value["instance_type"]
  provisioner = true
  app_type = "db"
}

module "app_servers" {
  depends_on = [module.database_servers]
  for_each = var.app_servers
  source = "./module"
  component_name = each.value["name"]
  instance_type = each.value["instance_type"]
  provisioner = true
  app_type = "app"
}
