output "aws_http_server_sg_details" {
  value = aws_security_group.http_server_sg
}

output "aws_http_server_details" {
  value = aws_instance.bink-http-servers
}

output "elb_details" {
  value = aws_elb.elb
}