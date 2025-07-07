# # s3.tf
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "mesh-terraform-state"  # Name this appropriately

#   # Prevent accidental deletion of this bucket
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# # Enable versioning
# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # Enable server-side encryption by default
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # Block all public access
# resource "aws_s3_bucket_public_access_block" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # Optional: Create DynamoDB table for state locking
# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = "mesh-terraform-state-lock"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# # Outputs
# output "s3_bucket_name" {
#   value       = aws_s3_bucket.terraform_state.id
#   description = "The name of the S3 bucket"
# }

# output "dynamodb_table_name" {
#   value       = aws_dynamodb_table.terraform_state_lock.id
#   description = "The name of the DynamoDB table"
# }