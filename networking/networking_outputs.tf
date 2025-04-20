output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "subnet_id" {
  description = "ID of the main subnet"
  value       = aws_subnet.main.id
}

output "redshift_security_group_id" {
  description = "ID of the Redshift security group"
  value       = aws_security_group.redshift.id
} 