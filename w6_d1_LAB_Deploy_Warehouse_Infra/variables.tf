variable "snowflake_account"{
    description = "Snowflake account identifier"
    type = string
}

variable "snowflake_username"{
    description = "username"
    type = string
}

variable "snowflake_password"{
    description = "password"
    type = string
    sensitive = true
}

variable "environment" {
  description = "Environment name (dev, staging, or prod)"
  type        = string
  default     = "dev"
}

variable "warehouses" {
  type = map(object({
    size           = string
    monitor_quota  = number
  }))
}

variable "database_names" {
  type    = list(string)
  default = ["STREAMPULSE_PROD", "STREAMPULSE_STAGING"]
}

variable "schema_names" {
  type    = list(string)
  default = ["RAW", "STAGING", "ANALYTICS", "MARTS"]
}

variable "role_names" {
  type    = list(string)
  default = ["LOADER", "TRANSFORMER", "ANALYST", "REPORTER", "DEVELOPER", "DATA_ADMIN"]
}