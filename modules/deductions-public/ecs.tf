resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.environment}-${var.component_name}-ecs-cluster"
}

# resource "aws_ecs_task_definition" "task" {
#   family                   = "app"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"
#   memory                   = "512"
#   execution_role_arn       = "arn:aws:iam::327778747031:role/ecsTaskExecutionRole"

#   container_definitions = <<DEFINITION
# [
#   {
#     "cpu": 256,
#     "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/deductions/gp-portal:latest",
#     "memory": 512,
#     "name": "app",
#     "networkMode": "awsvpc",
#     "portMappings": [
#       {
#         "containerPort": 3000,
#         "hostPort": 3000
#       }
#     ],
#     "logConfiguration": {
#         "logDriver": "awslogs",
#         "options": {
#             "awslogs-group": "/nhs/deductions/${var.environment}-${data.aws_caller_identity.current.account_id}/gp-portal",
#             "awslogs-region": "${var.region}",
#             "awslogs-stream-prefix": "log"
#         }
#     },
#     "secrets": [{
#         "name": "REACT_APP_GP_PORTAL_IDENTITY_URL",
#         "valueFrom": "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/gp_portal/identity_url"
#       }]
#   }
# ]
# DEFINITION
# }

data "aws_caller_identity" "current" {}

# resource "aws_ecs_service" "ecs-service" {
#   name            = "${var.environment}-${var.component_name}-ecs-service"
#   cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
#   task_definition = "${aws_ecs_task_definition.task.arn}"
#   desired_count   = "2"
#   launch_type     = "FARGATE"

#   network_configuration {
#     security_groups = ["${aws_security_group.ecs-tasks-sg.id}"]
#     subnets         = ["${aws_subnet.private-subnets[0].id}", "${aws_subnet.private-subnets[1].id}"]
#   }

#   load_balancer {
#     target_group_arn = "${aws_alb_target_group.alg-tg.arn}"
#     container_name   = "app"
#     container_port   = "3000"
#   }

#   depends_on = [
#     "aws_alb_listener.alg-listener",
#   ]
# }