provider "aws" {
  region = "us-east-1" # For most resources
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1" # For ACM and CloudFront
}
