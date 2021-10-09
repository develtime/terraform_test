provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

locals {
  application_type_map = {
    stage = {
      type  = "t3.micro"
      ami   = data.aws_ami.ubuntu.id
      count = 1
      tag   = "Netology stage"
      common_instancies = {
        "t3.micro" = data.aws_ami.ubuntu.id
      }
    }
    prod = {
      type  = "t3.large"
      ami   = data.aws_ami.ubuntu.id
      count = 2
      tag   = "Netology prod"
      common_instancies = {
        "t3.large" = data.aws_ami.ubuntu.id
        "t3.large" = data.aws_ami.ubuntu.id
      }
    }
  }
}


resource "aws_instance" "application_host" {
  ami = local.application_type_map[terraform.workspace].ami

  instance_type = local.application_type_map[terraform.workspace].type

  count = local.application_type_map[terraform.workspace].count

  tags = { "project" : local.application_type_map[terraform.workspace].tag }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

resource "aws_instance" "common_host" {
  for_each = local.application_type_map[terraform.workspace].common_instancies

  ami           = each.value
  instance_type = each.key
  tags          = { "project" : local.application_type_map[terraform.workspace].tag }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
