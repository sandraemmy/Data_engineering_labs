resource "snowflake_role" "this" {
  for_each = toset(var.role_names)

  name    = "${local.name_prefix}_${upper(each.key)}"
  comment = "Managed by Terraform - StreamPulse ${each.key} role"
}

resource "snowflake_grant_account_role" "transformer_to_data_admin" {
  role_name        = snowflake_role.this["TRANSFORMER"].name
  parent_role_name = snowflake_role.this["DATA_ADMIN"].name
}

resource "snowflake_grant_account_role" "analyst_to_data_admin" {
  role_name        = snowflake_role.this["ANALYST"].name
  parent_role_name = snowflake_role.this["DATA_ADMIN"].name
}

resource "snowflake_grant_account_role" "loader_to_transformer" {
  role_name        = snowflake_role.this["LOADER"].name
  parent_role_name = snowflake_role.this["TRANSFORMER"].name
}

resource "snowflake_grant_account_role" "reporter_to_analyst" {
  role_name        = snowflake_role.this["REPORTER"].name
  parent_role_name = snowflake_role.this["ANALYST"].name
}