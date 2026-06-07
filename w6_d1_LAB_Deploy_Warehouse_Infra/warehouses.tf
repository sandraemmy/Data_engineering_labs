resource "snowflake_warehouse" "this" {
  for_each = var.warehouses

  name                = "${local.name_prefix}_${upper(each.key)}_WH"
  warehouse_size      = each.value.size
  auto_suspend        = 60 
  auto_resume         = true
  initially_suspended = true

  resource_monitor    = snowflake_resource_monitor.this[each.key].name

  comment = "Managed by Terraform - StreamPulse Warehouse"
}