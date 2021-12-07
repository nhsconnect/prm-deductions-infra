locals {
  nems = {
    name = "nems-event-processor"
    title = "NEMS Event Processor"
  }

  nems_observability_queue = {
    name = nonsensitive(data.aws_ssm_parameter.mesh_forwarder_nems_observability_queue.value)
    title = "Incoming NEMS Observability Queue"
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
  task_widget_definitions = [
    {
      metric_type = "cpu"
      name = local.nems.name
      title = "${local.nems.title} CPU"
    },
    {
      metric_type = "memory"
      name = local.nems.name
      title = "${local.nems.title} Memory"
    },
    {
      metric_type = "cpu"
      name = local.mesh.name
      title = "${local.mesh.title} CPU"
    },
    {
      metric_type = "memory"
      name = local.mesh.name
      title = "${local.mesh.title} Memory"
    },
    {
      metric_type = "cpu"
      name = local.pds_adaptor.name
      title = "${local.pds_adaptor.title} CPU"
    },
    {
      metric_type = "memory"
      name = local.pds_adaptor.name
      title = "${local.pds_adaptor.title} Memory"
    },
    {
      metric_type = "cpu"
      name = local.suspensions.name
      title = "${local.suspensions.title} CPU"
    },
    {
      metric_type = "memory"
      name = local.suspensions.name
      title = "${local.suspensions.title} Memory"
    }
  ]
}

module "task_widgets" {
  for_each = {
    for i, def in local.task_widget_definitions : i => def
  }
  source = "./widgets/task_widget"
  environment = var.environment
  component = each.value
}

module "error_count_widgets" {
  for_each = {
    nems = local.nems,
    mesh = local.mesh,
    pds_adaptor = local.pds_adaptor
  }
  source = "./widgets/error_count_widget"
  component = each.value
}

module "health_widgets" {
  for_each = {
    nems = local.nems
    pds_adaptor = local.pds_adaptor
    suspensions = local.suspensions
  }
  source = "./widgets/health_widget"
  component = each.value
  environment = var.environment
}

module "queue_metrics_widgets" {
  for_each = {
    nems_observability_queue = local.nems_observability_queue
  }
  source = "./widgets/queue_metrics_widget"
  component = each.value
  environment = var.environment
}

locals {
  mesh_inbox_count = {
    type = "metric"
    properties = {
      metrics = [
          [ "MeshForwarder", "MeshInboxMessageCount" ]
      ],
      region = var.region
      title = "MESH Inbox Message Count"
      view = "timeSeries"
      stat = "Average"
    }
  }

  all_widgets = concat([
      local.mesh_inbox_count
    ],
    values(module.queue_metrics_widgets).*.widget,
    values(module.error_count_widgets).*.widget,
    values(module.health_widgets).*.widget,
    values(module.task_widgets).*.widget
  )
}

resource "aws_cloudwatch_dashboard" "continuity_dashboard" {
  dashboard_body = jsonencode({
    widgets = local.all_widgets
  })
  dashboard_name = "ContinuityDashboard${title(var.environment)}"
}

#    suspensions_observability_queue_name = data.aws_ssm_parameter.suspensions_observability_queue_name.value
#    nems_cluster_name = data.aws_ssm_parameter.nems_cluster_name.value
#    incoming_nems_events_queue_name = data.aws_ssm_parameter.incoming_nems_events_queue_name.value,
#    nems_events_dlq_name = data.nems_events_dlq_name,
#    nems_undhandled_queue_name = data.nems_undhandled_queue_name
