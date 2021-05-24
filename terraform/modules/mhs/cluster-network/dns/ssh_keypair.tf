resource "aws_key_pair" "dns-key" {
  key_name   = "mhs-dns-${var.environment}-${var.cluster_name}-ssh-key"
  public_key = file("${path.module}/ssh/id_rsa.pub")
  tags = {
    Name = "mhs-dns-${var.environment}-${var.cluster_name}-ssh-key"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}