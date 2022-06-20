locals {
  repo_all_widgets = concat(
    values(module.repo_queue_metrics_widgets).*.widget,
    values(module.repo_error_count_widgets).*.widget,
    [module.repo_health_widgets["re_registration_service"].widget],
  values(module.repo_task_widgets).*.widget
  )

  repo_queue_widget_definitions = [
    {
      name  = "${var.environment}-re-registration-service-re-registrations"
      title = "Re-registrations Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-negative-acknowledgments"
      title = "Negative Acknowledgements Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-negative-acknowledgments-observability"
      title = "Negative Acknowledgements Observability Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-small-ehr"
      title = "Small EHR Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-small-ehr-observability"
      title = "Small EHR Observability Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-large-ehr"
      title = "Large EHR Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-large-ehr-observability"
      title = "Large EHR Observability Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-large-message-fragments"
      title = "Large Fragments Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-large-message-fragments-observability"
      title = "Large Fragments Observability Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-positive-acknowledgements-observability"
      title = "Positive Acknowledgements Observability Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-ehr-complete"
      title = "EHR Complete Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-ehr-complete-observability"
      title = "EHR Complete Observability Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-transfer-complete"
      title = "Transfer Complete Queue"
    },
    {
      name  = "${var.environment}-ehr-transfer-service-transfer-complete-observability"
      title = "Transfer Complete Observability Queue"
    }
  ]

  re_registration_service = {
    name  = "re-registration-service"
    title = "Re-registration Service"
  }

  ehr_transfer_service = {
    name  = "ehr-transfer-service"
    title = "EHR Transfer Service"
  }

  repo_task_widget_components  = [
    local.re_registration_service, local.ehr_transfer_service
  ]
  repo_task_widget_types       = ["cpu", "memory"]
  repo_task_widget_definitions = [
  for pair in setproduct(local.repo_task_widget_types, local.repo_task_widget_components) : {
    component = pair[1]
    type      = pair[0]
  }
  ]
}

module "repo_task_widgets" {
  for_each    = {
  for i, def in local.repo_task_widget_definitions : i => def
  }
  source      = "./widgets/task_widget"
  environment = var.environment
  component   = each.value.component
  metric_type = each.value.type
}

module "repo_error_count_widgets" {
  for_each  = {
    re_registration_service = local.re_registration_service
    ehr_transfer_service = local.ehr_transfer_service
  }
  source    = "./widgets/error_count_widget"
  component = each.value
}

module "repo_health_widgets" {
  for_each    = {
    re_registration_service = local.re_registration_service
    ehr_transfer_service = local.ehr_transfer_service
  }
  source      = "./widgets/health_widget"
  component   = each.value
  environment = var.environment
}

module "repo_queue_metrics_widgets" {
  for_each    = {
  for i, def in local.repo_queue_widget_definitions : i => def
  }
  source      = "./widgets/queue_metrics_widget"
  component   = each.value
  environment = var.environment
}

resource "aws_cloudwatch_dashboard" "repository_dashboard" {
  dashboard_body = jsonencode({
    widgets = local.repo_all_widgets
  })
  dashboard_name = "RepositoryDashboard${title(var.environment)}"
}