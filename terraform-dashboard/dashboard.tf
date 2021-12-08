locals {
  all_widgets = concat([{
    type = "metric"
    properties = {
      metrics = [
        ["MeshForwarder", "MeshInboxMessageCount"]
      ],
      region = var.region
      title  = "MESH Inbox Message Count"
      view   = "timeSeries"
      stat   = "Average"
    }
    }
    ],
    values(module.queue_metrics_widgets).*.widget,
    values(module.error_count_widgets).*.widget,
    values(module.health_widgets).*.widget,
    values(module.task_widgets).*.widget
  )
  nems = {
    name  = "nems-event-processor"
    title = "NEMS Event Processor"
  }

  queue_widget_definitions = [
    {
      name  = "${var.environment}-mesh-forwarder-nems-events-observability-queue"
      title = "MESH Forwarder Observability Queue"
    },
    {
      name  = "${var.environment}-nems-event-processor-incoming-queue"
      title = "NEMS Event Processor Incoming Queue"
    },
    {
      name  = "${var.environment}-nems-event-processor-suspensions-observability-queue"
      title = "NEMS Processor Suspensions Observability Queue"
    },
    {
      name  = "${var.environment}-nems-event-processor-unhandled-events-queue"
      title = "NEMS Event Processor Unhandled Queue"
    },
    {
      name  = "${var.environment}-nems-event-processor-dlq"
      title = "NEMS Event Processor DLQ"
    },
    {
      name  = "${var.environment}-suspension-service-suspensions-queue"
      title = "Suspension Service Incoming Queue"
    },
    {
      name  = "${var.environment}-suspension-service-not-suspended-observability-queue"
      title = "Suspension Service Not Suspended Observability Queue"
    }
  ]
  mesh = {
    name  = "mesh-forwarder"
    title = "MESH Forwarder"
  }
  pds_adaptor = {
    name  = "pds-adaptor"
    title = "PDS Adaptor"
  }
  suspensions = {
    name  = "suspension-service"
    title = "Suspension Service"
  }

  task_widget_components = [local.nems, local.mesh, local.pds_adaptor, local.suspensions]
  task_widget_types = [ "cpu", "memory"]
  task_widget_definitions = [
  for pair in setproduct(local.task_widget_components, local.task_widget_types) : {
      component = pair[0]
      type  = pair[1]
    }
  ]
}

module "task_widgets" {
  for_each = {
    for i, def in local.task_widget_definitions : i => def
  }
  source      = "./widgets/task_widget"
  environment = var.environment
  component   = each.value.component
  metric_type = each.value.type
}

module "error_count_widgets" {
  for_each = {
    nems        = local.nems,
    mesh        = local.mesh,
    pds_adaptor = local.pds_adaptor
  }
  source    = "./widgets/error_count_widget"
  component = each.value
}

module "health_widgets" {
  for_each = {
    nems        = local.nems
    pds_adaptor = local.pds_adaptor
    suspensions = local.suspensions
  }
  source      = "./widgets/health_widget"
  component   = each.value
  environment = var.environment
}

module "queue_metrics_widgets" {
  for_each = {
    for i, def in local.queue_widget_definitions : i => def
  }
  source      = "./widgets/queue_metrics_widget"
  component   = each.value
  environment = var.environment
}

resource "aws_cloudwatch_dashboard" "continuity_dashboard" {
  dashboard_body = jsonencode({
    widgets = local.all_widgets
  })
  dashboard_name = "ContinuityDashboard${title(var.environment)}"
}
