terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Europe (Stockholm) eu-north-1
provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

## A VPC
resource "aws_vpc" "DevOpsCodeChallengeVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Project = "DevOpsCodeChallenge"
  }

}

# Internet Gateway for the VPC 
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.DevOpsCodeChallengeVPC.id}"
}

# Default Gateway
resource "aws_route_table" "rt" {
    vpc_id = "${aws_vpc.DevOpsCodeChallengeVPC.id}"
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
}

## A private subnet
resource "aws_subnet" "private" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.DevOpsCodeChallengeVPC.id
  tags = {
    Project = "DevOpsCodeChallenge"
  }
}


## A public subnet
resource "aws_subnet" "public" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.DevOpsCodeChallengeVPC.id
  map_public_ip_on_launch = "true"
  tags = {
    Project = "DevOpsCodeChallenge"
  }
}

## An IAM role with S3 access
resource "aws_iam_role" "S3AccessRole" {
  name = "S3AccessRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "S3AccessPolicy" {
  role = aws_iam_role.S3AccessRole.name

  policy = jsonencode({
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["s3:*"],
        "Resource": ["*"]
      }
        ]
  })
}

## An EC2 instance with the previously created role attached, inside the private subnet of the created VPC
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.S3AccessRole.name
}


# Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type ami-0bcf2639b551f6b31
resource "aws_instance" "ec2Private" {
  ami           = "ami-0bcf2639b551f6b31"
  instance_type = "t3.nano"
  key_name = "delta"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id = aws_subnet.private.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  tags = {
    Name = "ec2Private"
  }
}

## An EC2 instance with no role attached, inside the public subnet of the created VPC
## Bootstrap this instance with NGINX
resource "aws_instance" "ec2Public" {
  ami           = "ami-0bcf2639b551f6b31"                                                          
  instance_type = "t3.nano"
  key_name = "delta"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  user_data = "${file("bootstrap-nginx.sh")}"
  subnet_id = aws_subnet.public.id
  tags = {
    Name = "ec2Public"
  }
}

## A load balancer in the public subnet of the created VPC Targeting the private EC2 instance
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public : aws_subnet.public.id ]
  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = aws_vpc.DevOpsCodeChallengeVPC.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.ec2Private.id
  port             = 22
}

## A security group Attached to the created EC2 instances
resource "aws_security_group" "sg" {
    vpc_id = "${aws_vpc.DevOpsCodeChallengeVPC.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

