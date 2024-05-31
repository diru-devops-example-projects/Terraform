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
  enable_dns_hostnames = true

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
resource "aws_subnet" "test-private-subnet-us-east-1a" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "test-private-subnet-us-east-1a"
  }
}

# Create a private Subnet in us-east-1b AV
resource "aws_subnet" "test-private-subnet-us-east-1b" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "test-private-subnet-us-east-1b"
  }
}

# Create internet gateway for the VPC
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-igw"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "test-public-rtb" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "test-public-rtb"
  }
}

# Associate public subnet us-east-1a with public route table
resource "aws_route_table_association" "public-rtb-association-1a" {
  subnet_id      = aws_subnet.test-public-subnet-us-east-1a.id
  route_table_id = aws_route_table.test-public-rtb.id
}
resource "aws_route_table_association" "public-rtb-association-1b" {
  subnet_id      = aws_subnet.test-public-subnet-us-east-1b.id
  route_table_id = aws_route_table.test-public-rtb.id
}



# Create a route table for private subnets
resource "aws_route_table" "private-rtb-us-east-1a" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "private-rtb-us-east-1a"
  }
}
resource "aws_route_table" "private-rtb-us-east-1b" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "private-rtb-us-east-1b"
  }
}

# Associate private subnet us-east-1a with private route table us-east-1a
resource "aws_route_table_association" "private-rtb-association-1a" {
  subnet_id = aws_subnet.test-private-subnet-us-east-1a.id
  route_table_id = aws_route_table.private-rtb-us-east-1a.id
}

# Associate private subnet us-east-1b with private route table us-east-1b
resource "aws_route_table_association" "private-rtb-association-1b" {
  subnet_id = aws_subnet.test-private-subnet-us-east-1b.id
  route_table_id = aws_route_table.private-rtb-us-east-1b.id
}
