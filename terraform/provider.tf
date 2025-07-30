provider "aws" {
  region = "us-east-2" # For most resources
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1" # For ACM and CloudFront
}
terraform {
  backend "s3" {
    bucket         = "<your-s3-bucket>"
    key            = "terraform/state"
    region         = "us-east-2"
    dynamodb_table = "<your-dynamodb-table>" # Optional for state locking
  }
}