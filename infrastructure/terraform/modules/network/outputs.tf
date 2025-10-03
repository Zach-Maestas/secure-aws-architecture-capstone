output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_rt_id" {
  value = aws_route_table.public.id
}

output "private_rt_ids" {
  value = aws_route_table.private[*].id # one per AZ / private subnet
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
