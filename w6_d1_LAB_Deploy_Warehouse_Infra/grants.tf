resource "snowflake_grant_privilege_to_account_role" "loader_wh" {
  privilege         = "USAGE"
  account_role_name = snowflake_role.this["LOADER"].name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this["LOADING"].name
  }
}

resource "snowflake_grant_privilege_to_account_role" "transformer_wh" {
  privilege         = "USAGE"
  account_role_name = snowflake_role.this["TRANSFORMER"].name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this["TRANSFORM"].name
  }
}

resource "snowflake_grant_privilege_to_account_role" "analyst_wh" {
  privilege         = "USAGE"
  account_role_name = snowflake_role.this["ANALYST"].name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this["ANALYTICS"].name
  }
}

resource "snowflake_grant_privilege_to_account_role" "reporter_wh" {
  privilege         = "USAGE"
  account_role_name = snowflake_role.this["REPORTER"].name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this["REPORTING"].name
  }
}

resource "snowflake_grant_privilege_to_account_role" "developer_wh" {
  privilege         = "USAGE"
  account_role_name = snowflake_role.this["DEVELOPER"].name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this["DEV"].name
  }
}



resource "snowflake_grant_privilege_to_account_role" "db_access" {
  for_each          = toset(var.database_names)
  privilege         = "USAGE"
  account_role_name = snowflake_role.this["DATA_ADMIN"].name
  
  on_account_object {
    object_type = "DATABASE"
    object_name = each.key
  }
}