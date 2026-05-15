resource "aws_appautoscaling_target" "urls_read" {
  count = local.use_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_read_max
  min_capacity       = var.autoscaling_read_min
  resource_id        = "table/${aws_dynamodb_table.urls.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "urls_read" {
  count = local.use_autoscaling ? 1 : 0

  name               = "${var.name}-${var.environment}-urls-read"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.urls_read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.urls_read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.urls_read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "urls_write" {
  count = local.use_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_write_max
  min_capacity       = var.autoscaling_write_min
  resource_id        = "table/${aws_dynamodb_table.urls.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "urls_write" {
  count = local.use_autoscaling ? 1 : 0

  name               = "${var.name}-${var.environment}-urls-write"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.urls_write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.urls_write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.urls_write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "users_read" {
  count = local.use_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_read_max
  min_capacity       = var.autoscaling_read_min
  resource_id        = "table/${aws_dynamodb_table.users.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "users_read" {
  count = local.use_autoscaling ? 1 : 0

  name               = "${var.name}-${var.environment}-users-read"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.users_read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.users_read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.users_read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "users_write" {
  count = local.use_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_write_max
  min_capacity       = var.autoscaling_write_min
  resource_id        = "table/${aws_dynamodb_table.users.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "users_write" {
  count = local.use_autoscaling ? 1 : 0

  name               = "${var.name}-${var.environment}-users-write"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.users_write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.users_write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.users_write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}
