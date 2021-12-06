locals {
  widgets_json = data.template_file.widgets.rendered
}

module "task_widgets" {
  for_each = {
    nems_processor_cpu = {
      type = "cpu"
      component = "nems-event-processor"
      title = "NEMS Event Processor CPU"
    }
    nems_processor_memory = {
      type = "memory"
      component = "nems-event-processor"
      title = "NEMS Event Processor Memory"
    }
  }
  source = "./widgets/task_widget"
  environment = var.environment
  component = each.value.component
  title = each.value.title
  metric_type = each.value.type
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
    task_cpu_widget = jsonencode(module.task_widgets.nems_processor_cpu.widget)
    task_memory_widget = jsonencode(module.task_widgets.nems_processor_memory.widget)
#    suspensions_observability_queue_name = data.aws_ssm_parameter.suspensions_observability_queue_name.value
#    nems_cluster_name = data.aws_ssm_parameter.nems_cluster_name.value
#    incoming_nems_events_queue_name = data.aws_ssm_parameter.incoming_nems_events_queue_name.value,
#    nems_events_dlq_name = data.nems_events_dlq_name,
#    nems_undhandled_queue_name = data.nems_undhandled_queue_name
  }
}