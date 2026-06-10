terraform {
 required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "terraform-state-ruthvijay"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
