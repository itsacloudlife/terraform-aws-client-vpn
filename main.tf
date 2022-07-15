
# vpn client admin guide https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/what-is.html

# create self signed certs for authentication https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/authentication-authrization.html

resource "aws_cloudwatch_log_group" "client_vpn_log_group" {
  name = "/aws/vpn/${var.stage}"
}

resource "aws_cloudwatch_log_stream" "client_vpn_log_stream" {
  name           = "${var.stage}-vpn"
  log_group_name = aws_cloudwatch_log_group.client_vpn_log_group.name
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description = "client vpn for ${var.stage}"

  server_certificate_arn = var.vpn_server_arn
  client_cidr_block      = var.client_cidr_block
  dns_servers            = ["${var.vpn_dns}"]

  authentication_options {
    type = "certificate-authentication"

    # client certificate arn
    root_certificate_chain_arn = var.vpn_client_arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn_log_group.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.client_vpn_log_stream.name
  }

  tags = {
    Name  = "${var.stage}"
    notes = "managed by terraform"
  }
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_connection" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.subnet_id

}

# There are still additional things you need to do to make this work because TF doesnt have all the neccesary resources
#
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-working-rules.html#cvpn-working-rule-authorize 
# add both local network cidr as well as 0.0.0.0/0 for internet traffic 
#
# you also need to update the config file to have the client cert and client key



