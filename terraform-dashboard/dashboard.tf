locals {
  widgets_json = data.template_file.widgets.rendered

  task_memory_log_group = "/aws/ecs/containerinsights/${var.environment}-nems-event-processor-ecs-cluster/performance"
  task_memory_widget = {
    type = "log"
    x = 0
    y = 12
    properties = {
      query = "SOURCE '${local.task_memory_log_group}' | ${file("task_memory_widget_query.txt")}"
      region = var.region
      title = "Nems Events Processor Container"
      view = "timeSeries"
      stacked = false
    }
  }
  task_memory_widget_json = jsonencode(local.task_memory_widget)
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
    task_memory_widget = local.task_memory_widget_json
#    suspensions_observability_queue_name = data.aws_ssm_parameter.suspensions_observability_queue_name.value
#    nems_cluster_name = data.aws_ssm_parameter.nems_cluster_name.value
#    incoming_nems_events_queue_name = data.aws_ssm_parameter.incoming_nems_events_queue_name.value,
#    nems_events_dlq_name = data.nems_events_dlq_name,
#    nems_undhandled_queue_name = data.nems_undhandled_queue_name
  }
}