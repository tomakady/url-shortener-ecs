# DynamoDB Table for URL mappings
resource "aws_dynamodb_table" "main" {
  name         = var.project_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = merge(
    var.tags,
    {
      Name = var.project_name
    }
  )
}
