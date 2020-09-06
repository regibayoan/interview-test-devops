data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id
}

data "aws_ami" "ubuntu-18_04" {
  most_recent = true
  owners      = ["${var.ubuntu_account_number}"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}