output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_ips" {
  value = aws_eip.nat.*.public_ip
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "private_route_table_ids" {
  value = aws_route_table.private.*.id
}

output "main_nacl_id" {
  value = aws_network_acl.main.id
}
