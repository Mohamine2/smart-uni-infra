# ==========================================================================
# 1. ROLES & SECURITY CONFIGURATION (IAM for SSM Session Manager)
# ==========================================================================

# Allows the EC2 instance to assume an AWS role
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches the official AWS policy for Systems Manager (SSM) to the role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Creates the "instance profile" that will be physically attached to the EC2 machine
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# ==========================================================================
# 2. AUTOMATIC IMAGE SELECTION (UBUNTU 24.04 LTS AMI)
# ==========================================================================

# Terraform will dynamically look up the latest official stable Ubuntu image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical's official ID (creators of Ubuntu)

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ==========================================================================
# 3. SMART-UNI EC2 INSTANCE CREATION
# ==========================================================================

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  root_block_device {
    volume_size           = var.instance_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  subnet_id =  aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Automation script at startup (Bootstrap)
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io docker-compose-v2
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "${var.project_name}-server"
  }
}