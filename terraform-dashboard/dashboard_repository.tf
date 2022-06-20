locals {
  repo_all_widgets = concat(
    values(module.repo_queue_metrics_widgets).*.widget,
    values(module.repo_error_count_widgets).*.widget,
    [module.repo_health_widgets["re_registration_service"].widget]
  )

  repo_queue_widget_definitions = [
    {
      name  = "${var.environment}-re-registration-service-re-registrations-queue"
      title = "Re-registrations Queue"
    },
    {
      name  = "${var.environment}-negative-acknowledgments-queue"
      title = "Negative Acknowledgements Queue"
    },
    {
      name  = "${var.environment}-negative-acknowledgments-observability-queue"
      title = "Negative Acknowledgements Observability Queue"
    },
    {
      name  = "${var.environment}-small-ehr-queue"
      title = "Small EHR Queue"
    },
    {
      name  = "${var.environment}-small-ehr-observability-queue"
      title = "Small EHR Observability Queue"
    },
    {
      name  = "${var.environment}-large-ehr-queue"
      title = "Large EHR Queue"
    },
    {
      name  = "${var.environment}-large-ehr-observability-queue"
      title = "Large EHR Observability Queue"
    },
    {
      name  = "${var.environment}-large-message-fragments-queue"
      title = "Large Fragments Queue"
    },
    {
      name  = "${var.environment}-large-message-fragments-observability-queue"
      title = "Large Fragments Observability Queue"
    },
    {
      name  = "${var.environment}-positive-acknowledgements-observability-queue"
      title = "Positive Acknowledgements Observability Queue"
    },
    {
      name  = "${var.environment}-ehr-complete-queue"
      title = "EHR Complete Queue"
    },
    {
      name  = "${var.environment}-ehr-complete-observability-queue"
      title = "EHR Complete Observability Queue"
    },
    {
      name  = "${var.environment}-transfer-complete-queue"
      title = "Transfer Complete Queue"
    },
    {
      name  = "${var.environment}-transfer-complete-observability-queue"
      title = "Transfer Complete Observability Queue"
    }
  ]

  re_registration_service = {
    name  = "re-registration-service"
    title = "Re-registration Service"
  }

  repo_task_widget_components  = [
    local.re_registration_service
  ]
  repo_task_widget_types       = ["cpu", "memory"]
  repo_task_widget_definitions = [
  for pair in setproduct(local.repo_task_widget_types, local.repo_task_widget_components) : {
    component = pair[1]
    type      = pair[0]
  }
  ]
}

module "repo_error_count_widgets" {
  for_each  = {
    re_registration_service = local.re_registration_service
  }
  source    = "./widgets/error_count_widget"
  component = each.value
}

module "repo_health_widgets" {
  for_each    = {
    re_registration_service = local.re_registration_service
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