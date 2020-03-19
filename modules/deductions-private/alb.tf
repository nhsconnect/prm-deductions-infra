# resource "aws_alb" "alb" {
#   name            = "${var.environment}-${var.component_name}-alb"
#   subnets         = module.vpc.public_subnets
#   security_groups = [aws_security_group.deductions-private-alb-sg.id]
#
#   tags = {
#     Terraform = "true"
#     Environment = var.environment
#     Deductions-VPC = var.component_name
#   }
# }
#
# resource "aws_alb_listener" "alb-listener" {
#   load_balancer_arn = aws_alb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"
#
#   default_action {
#     type = "fixed-response"
#
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Error"
#       status_code  = "501"
#     }
#   }
# }
#
# resource "aws_alb_listener" "alb-listener-https" {
#   load_balancer_arn = aws_alb.alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#
#   ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn = aws_acm_certificate_validation.admin-cert-validation.certificate_arn
#
#   default_action {
#     type = "fixed-response"
#
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Error"
#       status_code  = "501"
#     }
#   }
# }
#
# resource "aws_lb_listener_certificate" "example" {
#   listener_arn    = aws_alb_listener.alb-listener-https.arn
#   certificate_arn = aws_acm_certificate_validation.gp2gp-cert-validation.certificate_arn
# }
#
# resource "aws_lb_listener_certificate" "gp-to-repo-listener-cert" {
#   listener_arn    = aws_alb_listener.alb-listener-https.arn
#   certificate_arn = aws_acm_certificate_validation.gp-to-repo-cert-validation.certificate_arn
# }
#
# resource "aws_lb_listener_certificate" "generic-component-listener-cert" {
#   listener_arn    = aws_alb_listener.alb-listener-https.arn
#   certificate_arn = aws_acm_certificate_validation.generic-component-cert-validation.certificate_arn
# }
#
#
