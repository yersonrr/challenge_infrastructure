output "urls_table_name" {
  description = "Name of the short URL DynamoDB table."
  value       = aws_dynamodb_table.urls.name
}

output "urls_table_arn" {
  description = "ARN of the short URL DynamoDB table."
  value       = aws_dynamodb_table.urls.arn
}

output "users_table_name" {
  description = "Name of the user authentication DynamoDB table."
  value       = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  description = "ARN of the user authentication DynamoDB table."
  value       = aws_dynamodb_table.users.arn
}

output "table_names" {
  description = "Map of logical table keys to DynamoDB table names."
  value = {
    urls  = aws_dynamodb_table.urls.name
    users = aws_dynamodb_table.users.name
  }
}

output "table_arns" {
  description = "Map of logical table keys to DynamoDB table ARNs."
  value = {
    urls  = aws_dynamodb_table.urls.arn
    users = aws_dynamodb_table.users.arn
  }
}

output "urls_owner_gsi_name" {
  description = "Name of the ownerId-createdAt GSI on the URLs table, or null if disabled."
  value       = var.enable_urls_owner_gsi ? "ownerId-createdAt-index" : null
}

output "users_email_gsi_name" {
  description = "Name of the email GSI on the users table, or null if disabled."
  value       = var.enable_users_email_gsi ? "email-index" : null
}
