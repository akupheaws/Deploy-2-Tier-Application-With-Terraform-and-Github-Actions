provider "aws" {
  region = "us-east-2" # For most resources
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1" # For ACM and CloudFront
}
terraform {
  backend "s3" {
    bucket         = "deploy-2-tier-app-with-terraform"
    key            = "state"
    region         = "us-east-1"
    dynamodb_table = "state-locking" # Optional for state locking
  }
}