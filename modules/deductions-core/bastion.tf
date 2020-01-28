data "aws_ami" "amazon_linux_2" {
 most_recent = true
 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
 filter {
   name = "architecture"
   values = ["x86_64"]
 }
 owners = ["137112412989"] #amazon
}

variable "prefix" {
  default = "brett"
}

resource "aws_instance" "bastion" {
    ami                             = data.aws_ami.amazon_linux_2.id
    instance_type                   = "t2.micro"
    vpc_security_group_ids          = [aws_security_group.bastion_az1_sg.id]
    associate_public_ip_address     = true
    subnet_id                       = local.subnet_id
    key_name                        = aws_key_pair.ssh_key.key_name
    iam_instance_profile            = "gocd_agent-prod"
    tags = {
        Name = "${var.prefix}-bastion-rds"
    }
}

locals {
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]
  ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/Yu/OpmlI5hN/xydpxFxnRh3TWs45eg7+sAjaGj6+J+HlKGCN+nm5KDHAUk+gEvDaEzC8b6DGrtsaSH/AHCmtfbpnCVP4kWDxbD233PJyKf2WwABZxyeMljzVgorhuRyjTtlgJlQq35GZq3/fMJ+bjYQx9AU81zxkXDubSY/kdhTNo+6qQYIJwHaIf5Os3Nb2x0K20ZiiRgT84sq5i0Bpb7skOLY2aRXc60TKI7RBpy2vodeQiakHn/5jgYqeja1X8H/KbEivnOjtez0TbXzGzU++tyQFP5FOAW/d+j14EO/vYZBv5oBiYbztW3UWV8/yr2mJgNS1fJV+aeEz9QiV bfisher@Bretts-MacBook-Pro.local"
}

resource "aws_security_group" "bastion_az1_sg" {
    vpc_id    = local.vpc_id
    name      = "${var.prefix}-bastion-sg"
    ingress {
        protocol    = "tcp"
        from_port   = 22
        to_port     = 22
        cidr_blocks = concat(split(",", "${data.aws_ssm_parameter.inbound_ips.value}"),
          ["10.0.0.0/8"])
    }
    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.prefix}-bastion-az1-sg"
    }
}

output "public_ip" {
    value = aws_instance.bastion.public_ip
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "nhs-deductions-${var.prefix}-bastion"
  public_key = local.ssh_key
}