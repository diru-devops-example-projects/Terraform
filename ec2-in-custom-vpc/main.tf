terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "test-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "test-vpc"
  }
}

# Create a public Subnet in us-east-1a AV
resource "aws_subnet" "test-public-subnet-us-east-1a" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "test-public-subnet-us-east-1a"
  }
}

# Create a public Subnet in us-east-1b AV
resource "aws_subnet" "test-public-subnet-us-east-1b" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "test-public-subnet-us-east-1b"
  }
}

# Create internet gateway for the VPC
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-igw"
  }
}

# Create a route table
resource "aws_route_table" "test-rtb" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "test-rtb"
  }
}
