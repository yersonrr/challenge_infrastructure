# Item attributes (not defined in the table schema):
# - longUrl (S)
# - ownerId (S)
# - createdAt (S)
# - expiresAt (N, Unix epoch seconds — used for TTL when enabled)
resource "aws_dynamodb_table" "urls" {
  name         = "${var.name}-${var.environment}-urls"
  billing_mode = var.billing_mode
  hash_key     = "shortCode"

  read_capacity  = try(local.provisioned_capacity.read_capacity, null)
  write_capacity = try(local.provisioned_capacity.write_capacity, null)

  attribute {
    name = "shortCode"
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.enable_urls_owner_gsi ? [1] : []
    content {
      name = "ownerId"
      type = "S"
    }
  }

  dynamic "attribute" {
    for_each = var.enable_urls_owner_gsi ? [1] : []
    content {
      name = "createdAt"
      type = "S"
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.enable_urls_owner_gsi ? [1] : []
    content {
      name            = "ownerId-createdAt-index"
      projection_type = "ALL"

      key_schema {
        attribute_name = "ownerId"
        key_type       = "HASH"
      }

      key_schema {
        attribute_name = "createdAt"
        key_type       = "RANGE"
      }

      read_capacity  = try(local.provisioned_capacity.read_capacity, null)
      write_capacity = try(local.provisioned_capacity.write_capacity, null)
    }
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = var.urls_ttl_enabled
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  deletion_protection_enabled = var.deletion_protection

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-urls"
  })
}

