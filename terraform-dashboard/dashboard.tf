locals {
  widgets_json = data.template_file.widgets.rendered

  nems = {
    name = "nems-event-processor"
    title = "NEMS Event Processor"
  }
  mesh = {
    name = "mesh-forwarder"
    title = "MESH Forwarder"
  }
  pds_adaptor = {
    name = "pds-adaptor"
    title = "PDS Adaptor"
  }
  suspensions = {
    name = "suspension-service"
    title = "Suspension Service"
  }
  memory = {
    title = "Memory"
  }
}

module "task_widgets" {
  for_each = {
    nems_cpu = {
      type = "cpu"
      component = local.nems.name
      title = "${local.nems.title} CPU"
    }
    nems_memory = {
      type = "memory"
      component = local.nems.name
      title = "${local.nems.title} Memory"
    }
    mesh_cpu = {
      type = "cpu"
      component = local.mesh.name
      title = "${local.mesh.title} CPU"
    }
    mesh_memory = {
      type = "memory"
      component = local.mesh.name
      title = "${local.mesh.title} Memory"
    }
    pds_adaptor_cpu = {
      type = "cpu"
      component = local.pds_adaptor.name
      title = "${local.pds_adaptor.title} CPU"
    }
    pds_adaptor_memory = {
      type = "memory"
      component = local.pds_adaptor.name
      title = "${local.pds_adaptor.title} Memory"
    }
    suspensions_cpu = {
      type = "cpu"
      component = local.suspensions.name
      title = "${local.suspensions.title} CPU"
    }
    suspensions_memory = {
      type = "memory"
      component = local.suspensions.name
      title = "${local.suspensions.title} Memory"
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
    mesh_cpu_widget = jsonencode(module.task_widgets.mesh_cpu.widget)
    mesh_memory_widget = jsonencode(module.task_widgets.mesh_memory.widget)
    nems_cpu_widget = jsonencode(module.task_widgets.nems_cpu.widget)
    nems_memory_widget = jsonencode(module.task_widgets.nems_memory.widget)
#    suspensions_observability_queue_name = data.aws_ssm_parameter.suspensions_observability_queue_name.value
#    nems_cluster_name = data.aws_ssm_parameter.nems_cluster_name.value
#    incoming_nems_events_queue_name = data.aws_ssm_parameter.incoming_nems_events_queue_name.value,
#    nems_events_dlq_name = data.nems_events_dlq_name,
#    nems_undhandled_queue_name = data.nems_undhandled_queue_name
  }
}