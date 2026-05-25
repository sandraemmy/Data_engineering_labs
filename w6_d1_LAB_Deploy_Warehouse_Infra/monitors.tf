output "deployed_environment" {
  description = "The environment is deployed"
  value       = var.environment
}

output "created_databases" {
  description = "List of databaseb created by Terraform"
  value       = [for db in snowflake_database.this : db.name]
}

output "created_warehouses" {
  description = "List of Warehouses configured"
  value       = [for wh in snowflake_warehouse.this : wh.name]
}