output "instance_public_ip" {
  description = "Public IP address of the monitoring instance"
  value       = aws_instance.monitoring.public_ip
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${aws_instance.monitoring.public_ip}:3000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_instance.monitoring.public_ip}:9090"
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ${path.module}/monitoring-stack-key.pem ec2-user@${aws_instance.monitoring.public_ip}"
}

output "private_key_path" {
  description = "Path to private key file"
  value       = "${path.module}/monitoring-stack-key.pem"
}