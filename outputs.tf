output "instance_id" {
  description = "EC2's Instance ID"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Server's Public IP"
  value       = aws_instance.web.public_ip
}