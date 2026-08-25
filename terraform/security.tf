resource "aws_security_group" "web" {
  name = "${var.project_name}-web-sg"
  description = "Firewallfor Smart-Uni web traffic"
  vpc_id = aws_vpc.main.id

  # Inbound traffic (Ingress): Allow HTTP (Port 80) from anywhere
  ingress {
    description = "HTTP from outside"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound traffic (Ingress): Allow HTTPS (Port 443) from anywhere
  ingress {
    description = "HTTPS from outside"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic (Egress): Allow ALL traffic to the outside
  # Essential for the instance to connect to DockerHub or run apt-get
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # -1 means "all protocols"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}