locals {
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

module "error_count_widgets" {
  for_each = {
    nems = local.nems, 
    mesh = local.mesh,
    pds_adaptor = local.pds_adaptor
  }
  source = "./widgets/error_count_widget"
  component = each.value.name
  title = each.value.title
}

locals {
  mesh_forwarder_nems_observability_queue = nonsensitive(data.aws_ssm_parameter.mesh_forwarder_nems_observability_queue.value)
  queue_metrics = {
    type = "metric"
    properties = {
      metrics = [
          [ "AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", "${local.mesh_forwarder_nems_observability_queue}" ],
          [ ".", "NumberOfMessagesSent", ".", "." ],
          [ ".", "NumberOfMessagesReceived", ".", "." ],
          [ ".", "ApproximateNumberOfMessagesDelayed", ".", "." ],
          [ ".", "ApproximateNumberOfMessagesVisible", ".", "." ],
          [ ".", "SentMessageSize", ".", "." ]
      ],
      region = var.region
      title = "Incoming NEMS Observability Queue"
      view = "timeSeries"
      stat = "Average",
      period = 300,
      stacked = false
    }
  }
  mesh_inbox_count = {
    type = "metric"
    properties = {
      metrics = [
          [ "MeshForwarder", "MeshInboxMessageCount", { "id": "m1" } ],
          [ { "expression": "ANOMALY_DETECTION_BAND(m1, 2)", "label": "MeshForwarder MeshInboxMessageCount (expected)", "color": "#95A5A6" } ]
      ],
      region = var.region
      title = "MESH Inbox Message Count"
      view = "timeSeries"
      stat = "Average",
      period = 300,
      stacked = false
    }
  }
  health_widget = {
    type = "metric"
    properties = {
      metrics = [
        [ "NemsEventProcessor", "Health", "Environment", var.environment ]
      ],
      region = var.region
      title = "NEMS Events Processor Health"
      view = "timeSeries"
      stat = "Average",
      period = 300,
      stacked = false
    }
  }

  all_widgets = concat([
      local.queue_metrics,
      local.mesh_inbox_count,
      local.health_widget
    ],
    values(module.error_count_widgets).*.widget,
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
