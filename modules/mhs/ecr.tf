resource "aws_ecr_repository" "mhs-inbound-repo" {
    name = "mhs/inbound"
}

resource "aws_ecr_repository" "mhs-outbound-repo" {
    name = "mhs/outbound"
}

resource "aws_ecr_repository" "scr-web-service-repo" {
    name = "mhs/scr-web-service"
}

resource "aws_ecr_repository" "mhs-route-repo" {
    name = "mhs/route"
}
