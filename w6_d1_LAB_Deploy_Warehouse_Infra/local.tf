locals{
    common_tags={
        managed_by = "terraform"
        project = "streampulse"
    }

name_prefix = upper(var.environment)

role_hierarchy = {
    "DATA_ADMIN"  = ["TRANSFORMER", "ANALYST"]
    "TRANSFORMER" = ["LOADER"]
    "ANALYST"     = ["REPORTER"]
  }

}

