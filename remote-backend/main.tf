terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "test" {
  ami = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  tags = {
    "Name" = "test"
  }
}

resource "aws_s3_bucket" "simple-bucket" {
  bucket = "dirudeen22-is-my-bucket"
}