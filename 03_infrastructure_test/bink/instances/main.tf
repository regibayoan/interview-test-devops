terraform {
  backend "s3" {
    bucket = "dev-bink-backend-state"
    key = "bink-instances-dev"
    region = "eu-west-2"
    dynamodb_table = "dev_bink_locks"
    encrypt = true
  }
}
/* Providers */
provider "aws" {
  region = "eu-west-2"
}

/* Default VPC */
resource "aws_default_vpc" "default" {

}

/* Security groups */
resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  vpc_id = aws_default_vpc.default.id // Which VPC should this security group be a part of

  // Inbound rules - which traffic from outside are allowed
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /* Outbound rules - security groups in AWS are stateful
  which means any changes applied to an incoming rule will 
  automatically be applied to an outgoing rule 
  However, Terraform disables the egress by default so 
  we have to allow this explicitly  */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_sg" {
  name   = "elb_sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Load Balancers */
resource "aws_elb" "elb" {
  name            = "bink-elb"
  subnets         = data.aws_subnet_ids.default_subnets.ids
  security_groups = [aws_security_group.elb_sg.id]
  instances       = values(aws_instance.bink-http-servers).*.id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol        = "http"
  }
}


/* HTTP Servers */
resource "aws_instance" "bink-http-servers" {
  #ami                    = "ami-0287acb18b6d8efff" // Ubuntu image
  ami                    = data.aws_ami.ubuntu-18_04.id
  key_name               = "bink-keypair"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_server_sg.id] // Refer to the sg resource id to avoid hard coding

  for_each  = data.aws_subnet_ids.default_subnets.ids
  subnet_id = each.value

  tags = {
    Name = "bink-http-servers_${each.value}"
  }



  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y",
      "sudo systemctl start apache2.service",
      "sudo systemctl enable apache2.service",
      "echo Welcome to Bink - This server is at ${self.public_dns} | sudo tee /var/www/html/index.html"
    ]
  }
}





