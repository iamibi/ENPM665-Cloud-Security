# Provider Block

# Currently pointing towards AWS
provider "aws" {
  access_key = "<access_key>"
  secret_key = "<access_key_secret>"
  region     = "us-east-1"
}

# Resource Block

resource "aws_instance" "enpm665_final_demo" {
  ami                  = "ami-0b0dcb5067f052a63"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.webtraffic.name]
  iam_instance_profile = aws_iam_instance_profile.cora_kai_instance_profile.name

  tags = {
    name = "Cobra Kai Demo"
  }
}

# INGRESS Rules
variable "ingress_rules" {
  type    = list(number)
  default = [80, 5000, 443]
}

# EGRESS Rules
variable "egress_rules" {
  type    = list(number)
  default = [80, 5000, 443, 25]
}

# AWS Security Group
resource "aws_security_group" "webtraffic" {
  name = "Allow Traffic"
  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_rules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.egress_rules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# IAM Role Policy

resource "aws_iam_role_policy" "cobra_kai_role_policy" {
  name = "cobra_kai_cloud_policy"
  role = aws_iam_role.developer.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# IAM Roles

# Developer Role
resource "aws_iam_role" "developer" {
  name = "developer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "iam:ListRolePolicies"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# System Admin Role
resource "aws_iam_role" "sys_admin" {
  name = "sys_admin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "iam:*"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "organizations:*"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "account:*"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_instance_profile" "cora_kai_instance_profile" {
  name = "cobra_kai_instance_profile"
  role = aws_iam_role.developer.name
}

# Elastic IP
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.enpm665_final_demo.id
}

output "EIP" {
  value = aws_eip.elastic_ip.public_ip
}
