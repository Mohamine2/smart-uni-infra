variable "project_name" {
  description = "Project name use to tag resources"
  type        = string
  default     = "smart-uni"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-3"
}

variable "instance_type" {
  description = "EC2 Instance Type (Free Tier)"
  type        = string
  default     = "t2.micro"
}