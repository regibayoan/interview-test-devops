provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "bink_backend_state" {
  bucket = "dev-bink-backend-state"
  // Prevents deletion of resource if there's an accidental terraform destroy
  lifecycle {
    prevent_destroy = false
  }
  // Enables versioning
  versioning {
    enabled = true
  }
  // Server Side Encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

// Locking - DynamoDB
resource "aws_dynamodb_table" "bink-backend-lock" {
  name         = "dev_bink_locks"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}