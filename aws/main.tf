provider "aws" {
  region  = var.region
  profile = var.curr_profile
}

resource "aws_instance" "testing1" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
}

output "ami" {
  value = aws_instance.testing1.ami
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.testing1.id
}

output "ip" {
  value = aws_eip.ip.public_ip
}
