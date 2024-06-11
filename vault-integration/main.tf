terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "vault" {
 address = "http://192.168.111.128:8200" # change address to yours
 skip_tls_verify = true
 skip_child_token = true

auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = "your-role-id"
      secret_id = "your-secret-id"
    }
  }
}


data "vault_kv_secret" "example" {
  path = "cred/test"
}


resource "aws_instance" "example" {
  ami = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"

  tags = {
    "secret" = data.vault_kv_secret.example.data["username"]
  }
}

