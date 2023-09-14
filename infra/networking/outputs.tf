

output vpc_id {
  value = aws_vpc.appvpc.id
}

output app_subnet_id {
  value = aws_subnet.app_subnet.id
}

output security_group_id {
  value = aws_security_group.app_sg.id
}