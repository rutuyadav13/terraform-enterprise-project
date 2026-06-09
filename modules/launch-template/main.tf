data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
resource "aws_iam_role" "ec2_role" {

  name = "asg-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ssm" {

  role       = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "profile" {

  name = "asg-profile"

  role = aws_iam_role.ec2_role.name
}
locals {

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
systemctl enable nginx
systemctl start nginx
EOF
)
}
resource "aws_launch_template" "lt" {

  name_prefix = "web-lt-"

  image_id = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.ec2_sg_id
  ]

  iam_instance_profile {

    name = aws_iam_instance_profile.profile.name
  }

  user_data = local.user_data

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "web-server"
    }
  }
}
