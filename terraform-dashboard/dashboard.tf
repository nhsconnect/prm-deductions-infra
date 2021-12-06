locals {
  widgets_json = data.template_file.widgets.rendered
}

module "task_cpu_widget" {
  source = "./widgets/task_widget"
  environment = var.environment
  component = "nems-event-processor"
  title = "NEMS Event Processor CPU"
  metric_type = "cpu"
}

module "task_memory_widget" {
  source = "./widgets/task_widget"
  environment = var.environment
  component = "nems-event-processor"
  title = "NEMS Event Processor Memory"
  metric_type = "memory"
}

resource "aws_cloudwatch_dashboard" "continuity_dashboard" {
  dashboard_body = local.widgets_json
  dashboard_name = "ContinuityDashboard${title(var.environment)}"
}

data "template_file" "widgets" {
  template = file("${path.module}/widget-template.json")

  vars = {
    region = var.region
    environment = var.environment
    mesh_forwarder_nems_observability_queue = data.aws_ssm_parameter.mesh_forwarder_nems_observability_queue.value
    task_cpu_widget = jsonencode(module.task_cpu_widget.widget)
    task_memory_widget = jsonencode(module.task_memory_widget.widget)
#    suspensions_observability_queue_name = data.aws_ssm_parameter.suspensions_observability_queue_name.value
#    nems_cluster_name = data.aws_ssm_parameter.nems_cluster_name.value
#    incoming_nems_events_queue_name = data.aws_ssm_parameter.incoming_nems_events_queue_name.value,
#    nems_events_dlq_name = data.nems_events_dlq_name,
#    nems_undhandled_queue_name = data.nems_undhandled_queue_name
  }
}