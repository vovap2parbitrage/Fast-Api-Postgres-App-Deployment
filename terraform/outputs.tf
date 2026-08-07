output "instance_ip" {
  description = "The public ip of the instance"
  value       = aws_instance.public_instance.public_ip
}