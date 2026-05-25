resource "snowflake_resource_monitor" "this" {
  for_each = var.warehouses 

  name         = "${local.name_prefix}_${upper(each.key)}_MONITOR"
  credit_quota = each.value.monitor_quota
  frequency    = "MONTHLY"

  
  notify_triggers   = [75] 
  suspend_triggers  = [100] 
}