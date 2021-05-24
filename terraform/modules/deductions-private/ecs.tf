resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.environment}-${var.component_name}-ecs-cluster"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}