output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_ips" {
  description = "The public IP addresses of the NAT gateways."
  value       = aws_eip.nat.*.public_ip
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public.*.id
}

output "public_subnet_cidr_blocks" {
  description = "The CIDR blocks of the public subnets."
  value       = aws_subnet.public.*.cidr_block
}

output "public_route_table_ids" {
  description = "The IDs of the public route tables."
  value       = aws_route_table.public.*.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = aws_subnet.private.*.id
}

output "private_subnet_cidr_blocks" {
  description = "The CIDR blocks of the private subnets."
  value       = aws_subnet.private.*.cidr_block
}

output "private_route_table_ids" {
  description = "The IDs of the private route tables."
  value       = aws_route_table.private.*.id
}

output "main_nacl_id" {
  description = "The ID of the main network ACL."
  value       = aws_network_acl.main.id
}

output "main_route_table_id" {
  description = "The ID of the main route table associated with the VPC."
  value       = aws_vpc.main.main_route_table_id
}
