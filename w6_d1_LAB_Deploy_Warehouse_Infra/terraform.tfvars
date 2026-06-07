snowflake_account  = "****"
snowflake_username = "*****"
snowflake_password = "****"
environment = "prod"

warehouses = {
  "LOADING"   = { size = "M",  monitor_quota = 500 }
  "TRANSFORM" = { size = "L",  monitor_quota = 1000 }
  "ANALYTICS" = { size = "L",  monitor_quota = 1000 }
  "REPORTING" = { size = "S",  monitor_quota = 200 }
  "DEV"       = { size = "XS", monitor_quota = 200 }
}