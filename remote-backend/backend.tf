terraform {
  backend "s3" {
    bucket = "dirudeen-terraform-backend-543"
    key = "terraform/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}