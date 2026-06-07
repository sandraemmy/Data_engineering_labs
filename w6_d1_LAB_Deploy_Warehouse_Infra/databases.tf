resource "snowflake_database" "this" {
  for_each = toset(var.database_names)

  name    = each.key
  comment = "Managed by Terraform - StreamPulse Database"
}

locals {
  database_schemas = {
    for pair in setproduct(var.database_names, var.schema_names) :
    "${pair[0]}_${pair[1]}" => {
      db_name     = pair[0]
      schema_name = pair[1]
    }
  }
}

resource "snowflake_schema" "this" {
  for_each = local.database_schemas

  database   = snowflake_database.this[each.value.db_name].name
  name       = each.value.schema_name
  is_managed = false
}