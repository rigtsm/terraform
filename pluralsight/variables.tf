
variable "aws_access_key" {}
variable "aws_secret_key"{}
variable "aws_region"{
    default = "us-east-1"
}

provider "aws" {
  access_key = "var.access_key"
  secret_key = "var.secret_key"
  region = "var.aws_region"
}

data "aws_ami" "alx" {
    most_recent = true
    owners = ["amazon"]
    filter{}
}

resource "aws_instance" "ex" {
  ami = "data.aws_ami.alx.id"
  instance_type = "t2.micro"
}
