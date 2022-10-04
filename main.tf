terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "BaldwinCloudWorks"

    workspaces {
      name = "DevOpsCodeChallenge"
    }
  }
}

locals {
  region         = "eu-north-1"
  project_name   = "DevOpsCodeChallenge"
  vpc_subnet     = "10.0.0.0/16"
  private_subnet = "10.0.1.0/24"
  public_subnet  = "10.0.2.0/24"
  ami            = "ami-0bcf2639b551f6b31"
  instance_type  = "t3.nano"
  key            = "delta"
}

provider "aws" {
  # After getting error 200~Error: error configuring Terraform AWS Provider: failed to get shared config profile, default.
  # https://discuss.hashicorp.com/t/error-error-configuring-terraform-aws-provider-failed-to-get-shared-config-profile-default/39417/3
  # profile = "default" 
  region  = local.region
}

## A VPC
resource "aws_vpc" "DevOpsCodeChallenge" {
  cidr_block = "10.0.0.0/16"
  tags = {
    project = local.project_name
  }
}

# Internet Gateway for the VPC 
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.DevOpsCodeChallenge.id
  tags = {
    project = local.project_name
  }
}

# Default Gateway
resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.DevOpsCodeChallenge.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    project = local.project_name
  }
}

## A private subnet
resource "aws_subnet" "private" {
  cidr_block = local.private_subnet
  vpc_id     = aws_vpc.DevOpsCodeChallenge.id
  tags = {
    project = local.project_name
  }
}

## A public subnet
resource "aws_subnet" "public" {
  cidr_block              = local.public_subnet
  vpc_id                  = aws_vpc.DevOpsCodeChallenge.id
  map_public_ip_on_launch = "true"
  tags = {
    project = local.project_name
  }
}
## An IAM role with S3 access
resource "aws_iam_role" "S3Access" {
  name = "S3Access"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
  tags = {
    project = local.project_name
  }
}

resource "aws_iam_role_policy" "S3Access" {
  role = aws_iam_role.S3Access.name
  policy = jsonencode({
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["s3:*"],
        "Resource" : ["*"]
      }
    ]
  })
}

## An EC2 instance with the previously created role attached, inside the private subnet of the created VPC
resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.S3Access.name
}

resource "aws_instance" "private" {
  ami                    = local.ami
  instance_type          = local.instance_type
  key_name               = local.key
  vpc_security_group_ids = ["${aws_security_group.this.id}"]
  subnet_id              = aws_subnet.private.id
  iam_instance_profile   = aws_iam_instance_profile.this.name
  tags = {
    project = local.project_name
    Name    = "private"
  }
}

## An EC2 instance with no role attached, inside the public subnet of the created VPC
## Bootstrap this instance with NGINX
resource "aws_instance" "public" {
  ami                    = local.ami
  instance_type          = local.instance_type
  key_name               = local.key
  vpc_security_group_ids = ["${aws_security_group.this.id}"]
  user_data              = file("bootstrap-nginx.sh")
  subnet_id              = aws_subnet.public.id
  tags = {
    project = local.project_name
    Name    = "public"
  }
}

## A load balancer in the public subnet of the created VPC Targeting the private EC2 instance
resource "aws_lb" "this" {
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = [for subnet in aws_subnet.private : aws_subnet.private.id]
  enable_deletion_protection = false
  tags = {
    project = local.project_name
  }
}

resource "aws_lb_target_group" "this" {
  port     = 22
  protocol = "TCP"
  vpc_id   = aws_vpc.DevOpsCodeChallenge.id
  tags = {
    project = local.project_name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "22"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  tags = {
    project = local.project_name
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.private.id
  port             = 22
}

## A security group Attached to the created EC2 instances
resource "aws_security_group" "this" {
  vpc_id = aws_vpc.DevOpsCodeChallenge.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    project = local.project_name
  }
}

