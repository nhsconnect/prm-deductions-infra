resource "aws_instance" "bastion_az1" {
    count  = tobool(data.aws_ssm_parameter.deductions_private_bastion.value) == true ? 1 : 0

    ami                             = "ami-00a1270ce1e007c27"
    instance_type                   = "t2.micro"
    vpc_security_group_ids          = [aws_security_group.bastion_az1_sg[0].id]
    associate_public_ip_address     = true
    subnet_id                       = aws_subnet.public-subnets[0].id
    key_name                        = "deductions-web-bastion"

    tags = {
        Name = "${var.environment}-${var.component_name}-bastion-az1"
    }
}

resource "aws_security_group" "bastion_az1_sg" {
    count  = tobool(data.aws_ssm_parameter.deductions_private_bastion.value) == true ? 1 : 0

    vpc_id    = aws_vpc.main-vpc.id
    name      = "${var.environment}-${var.component_name}-bastion-az1-sg"

    ingress {
        protocol    = "tcp"
        from_port   = 22
        to_port     = 22
        cidr_blocks = var.allowed_public_ips
    }

    ingress {
        protocol    = "tcp"
        from_port   = 8080
        to_port     = 8080
        cidr_blocks = var.allowed_public_ips
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-${var.component_name}-bastion-az1-sg"
    }
}
