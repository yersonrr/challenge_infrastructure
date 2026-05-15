# Item attributes (not defined in the table schema):
# - email (S)
# - passwordHash (S)
# - role (S)
resource "aws_dynamodb_table" "users" {
  name         = "${var.name}-${var.environment}-users"
  billing_mode = var.billing_mode
  hash_key     = "userId"

  read_capacity  = try(local.provisioned_capacity.read_capacity, null)
  write_capacity = try(local.provisioned_capacity.write_capacity, null)

  attribute {
    name = "userId"
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.enable_users_email_gsi ? [1] : []
    content {
      name = "email"
      type = "S"
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.enable_users_email_gsi ? [1] : []
    content {
      name            = "email-index"
      projection_type = "ALL"

      key_schema {
        attribute_name = "email"
        key_type       = "HASH"
      }

      read_capacity  = try(local.provisioned_capacity.read_capacity, null)
      write_capacity = try(local.provisioned_capacity.write_capacity, null)
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  deletion_protection_enabled = var.deletion_protection

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-users"
  })
}