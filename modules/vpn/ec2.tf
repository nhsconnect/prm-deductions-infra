resource "aws_instance" "vpn" {
  ami           = var.vpn_ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.vpn_ssh_key.key_name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = false
  }

  availability_zone = var.availability_zone

  iam_instance_profile = aws_iam_instance_profile.vpn-server.name

  subnet_id         = var.public_subnet_id
  source_dest_check = "false" # for VPN, this instance is a router

  vpc_security_group_ids = [
    local.dynamic_vpn_sg,
    aws_security_group.vpn_sg.id
  ]

  tags = {
    Name      = "VPN to ${var.environment} env"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_eip" "eip" {
  instance   = aws_instance.vpn.id
  vpc        = true
}

resource "null_resource" "provision" {
  depends_on = [
    aws_instance.vpn,
    aws_eip.eip
  ]
  connection {
    host        = aws_eip.eip.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = local.private_key
  }
  provisioner "remote-exec" {
    script = "${path.module}/scripts/bootstrap.sh"
  }
}
