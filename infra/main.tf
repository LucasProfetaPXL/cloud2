terraform {
  required_providers { 
    aws = { 
      source = "hashicorp/aws"
      version = ">=5.0" 
    } 
  }
  required_version = ">=1.4.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "def" { 
  default = true 
}

data "aws_subnets" "subs" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.def.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals { 
  subnet_id = data.aws_subnets.subs.ids[0] 
}

resource "aws_security_group" "sg" {
  name_prefix = "${var.name_prefix}-sg-"
  vpc_id      = data.aws_vpc.def.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = "${var.name_prefix}-sg" 
  }
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null
  user_data                   = file("${path.module}/script_backend.sh")
  
  user_data_replace_on_change = true
  
  tags = { 
    Name = "${var.name_prefix}-backend" 
  }
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null
  
  user_data = templatefile("${path.module}/script_frontend.sh", { 
    backend_ip = aws_instance.backend.private_ip 
  })
  
  user_data_replace_on_change = true
  
  tags = { 
    Name = "${var.name_prefix}-frontend" 
  }
  
  depends_on = [aws_instance.backend]
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "name_prefix" {
  type    = string
  default = "todoapp"
}

output "backend_public_ip" { 
  value = aws_instance.backend.public_ip 
}

output "backend_private_ip" { 
  value = aws_instance.backend.private_ip 
}

output "frontend_public_ip" { 
  value = aws_instance.frontend.public_ip 
}

output "frontend_url" {
  value = "http://${aws_instance.frontend.public_ip}"
}

output "backend_url" {
  value = "http://${aws_instance.backend.public_ip}:8080"
}