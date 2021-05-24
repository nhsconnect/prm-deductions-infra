locals {
  dns_count = 2
  dns_docker_image_url       = "${var.ecr_address}/mhs-unbound-dns:${var.unbound_image_version}"
}

resource "aws_instance" "dns" {
    count                           = local.dns_count
    ami                             = data.aws_ami.amazon-linux-2.id
    instance_type                   = "t2.micro"
    vpc_security_group_ids          = [aws_security_group.dns-sg.id]
    subnet_id                       = var.subnet_ids[count.index]
    key_name                        = aws_key_pair.dns-key.key_name

    user_data            = data.template_file.userdata.rendered
    iam_instance_profile = aws_iam_instance_profile.dns-server.name

    tags = {
        Name = "mhs-dns-${var.environment}-${var.cluster_name}-${count.index}"
        CreatedBy = var.repo_name
    }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.tpl")}"

  vars = {
    GLOBAL_FORWARD_SERVER = var.dns_global_forward_server
    FORWARD_ZONE_NAME      = var.dns_forward_zone
    HSCN_FORWARD_SERVER_1 = var.dns_hscn_forward_server_1
    HSCN_FORWARD_SERVER_2 = var.dns_hscn_forward_server_2
    DOCKER_IMAGE_URL      = local.dns_docker_image_url
  }
}
