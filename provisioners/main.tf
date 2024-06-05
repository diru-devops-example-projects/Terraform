terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# Create a vpc with name test_vpc
resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_cidr_block_value

  tags = {
    "Name" = "test-vpc"
  }
}

# create a public subnet in the test vpc
resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.subnet_cidr_block_value
  availability_zone       = var.subnet_availability_zone_value
  map_public_ip_on_launch = true
  tags = {
    "key" = "test-subnet"
  }
}


# create a internet gateway
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    "Name" = "test-igw"
  }
}

# Create a route table
resource "aws_route_table" "test_rtb" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }
  tags = {
    "Name" = "test-rtb"
  }
}

resource "aws_route_table_association" "route_tabe_assoc" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_rtb.id
}

# Create a security group
resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  description = "Allow TSL inbound and outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  tags = {
    "Name" = "test-sg"
  }
}

# Allow ssh traffic on port 22
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.test_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = "22"
  to_port           = "22"
  description       = "Allow SSH traffic"
}


# Allow Http traffic on port 80
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.test_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = "80"
  to_port           = "80"
  description       = "Allow HTTP traffic"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.test_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create a key pair
resource "aws_key_pair" "terraform-key" {
  key_name   = "Terraform-key"
  public_key = file("~/.ssh/terraform.pub")
}

# lunch ec2 instance
resource "aws_instance" "test_server" {
  ami                    = var.ec2_ami_value
  instance_type          = var.ec2_instance_type_value
  key_name               = aws_key_pair.terraform-key.key_name
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  subnet_id              = aws_subnet.test_subnet.id

  #   Establish a ssh connection to the instance
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/terraform")
  }

  provisioner "file" {
    source      = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",                  # Update package lists (for ubuntu)
      "sudo apt install python3-flask -y",     # Install flask package
      "nohup sudo python3 app.py &"
    ]
  }


  tags = {
    "Name" = "test-server"
  }

}





