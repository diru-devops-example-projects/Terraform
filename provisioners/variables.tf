variable "vpc_cidr_block_value" {
  description = "CIDR block value for VPC"
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block_value" {
  description = "CIDR block value for subnet"
  default = "10.0.0.0/24"
}

variable "subnet_availability_zone_value" {
  description = "The AV where subnet should be lunched"
  default = "us-east-1a"
}

variable "ec2_ami_value" {
  description = "AMI for EC2 instance"
  default = "ami-04b70fa74e45c3917"
}

variable "ec2_instance_type_value" {
  description = "Instance type for EC2 instance"
  default = "t2.micro"
}