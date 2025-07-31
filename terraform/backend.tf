terraform {
  backend "s3" {
    bucket         = "deploy-2-tier-app-with-terraform" # Replace with your bucket name
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-db"
    encrypt        = true
  }
}
//