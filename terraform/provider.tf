provider "aws" {
  region = "us-east-1" # For most resources
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1" # For ACM and CloudFront
}

terraform {
  backend "s3" {
    bucket         = "deploy-2-tier-app-with-terraform"   # Replace with your bucket name
    
    region         = "us-east-1"                    # Your AWS region
    
  }
}