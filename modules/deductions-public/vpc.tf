resource "aws_vpc" "main-vpc" {
    cidr_block = "${var.cidr}"

    tags = {
        Name = "${var.environment}-${var.component_name}-vpc"
    }
}