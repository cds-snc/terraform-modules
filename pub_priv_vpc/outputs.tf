output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_ip" {
  value = aws_eip.public_ip.public_ip
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
