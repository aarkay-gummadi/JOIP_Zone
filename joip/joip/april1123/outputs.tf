output "Ansible-instance_ip" {
  value = aws_instance.ansible_instance.public_ip
}