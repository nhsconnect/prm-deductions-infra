resource "aws_cloudwatch_dashboard" "continuity_dashboard" {
  dashboard_body = data.template_file.widgets.rendered
  dashboard_name = "ContinuityDashboard"
}

data "template_file" "widgets" {
  template = file("${path.module}/widget-template.json")

  vars = {
    region = var.region,
    environment = var.environment,
    mesh_forwarder_nems_observability_queue = data.aws_ssm_parameter.mesh_forwarder_nems_observability_queue.value
  }
}