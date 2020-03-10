resource "aws_lb" "deductor_mq_console_nlb" {
  name               = "${var.environment}-deductor-mq-console-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  count = var.mq_allow_public_console_access == true ? 1 : 0

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_lb_listener" "deductor_mq_console_nlb_listener" {
  load_balancer_arn = aws_lb.deductor_mq_console_nlb[count.index].arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mq_console_nlb_listener_tg[count.index].arn
  }

  count = var.mq_allow_public_console_access == true ? 1 : 0
}

resource "aws_lb_target_group" "mq_console_nlb_listener_tg" {
  name          = "${var.environment}-mq-console-nlb-listener-tg"
  port          = 8162
  protocol      = "TCP"
  vpc_id        = module.vpc.vpc_id
  target_type   = "ip"

  count = var.mq_allow_public_console_access == true ? 1 : 0
}

resource "aws_lb_target_group_attachment" "attachment" {
    target_group_arn = aws_lb_target_group.mq_console_nlb_listener_tg[0].arn
    target_id        = element(aws_mq_broker.deductor_mq_broker.instances.*.ip_address, count.index)
    port             = 8162

    count = var.mq_allow_public_console_access == true ? 2 : 0
}
