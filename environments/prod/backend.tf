terraform {
  backend "s3" {
    bucket         = "terraform-state-ruthvijay"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}