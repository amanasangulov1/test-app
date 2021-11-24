terraform {
  backend "s3" {
    bucket         = "ubuntu-eks-bucket"
    key            = "eks_cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-s3-backend-lock"
    encrypt        = true
  }
}

# locking part

resource "aws_dynamodb_table" "tf_remote_state_lock" {
  hash_key = "LockID"
  name     = "terraform-eks-21b-backend-lock"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}