locals {
  repo_all_widgets = concat(
  values(module.repo_error_count_widgets).*.widget,
  [module.repo_health_widgets["re_registration_service"].widget]
  )

  repo_queue_widget_definitions = [
    {
      name  = "${var.environment}-re-registration-service-re-registrations-queue"
      title = "Re-registrations Queue"
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

resource "aws_cloudwatch_dashboard" "repository_dashboard" {
  dashboard_body = jsonencode({
    widgets = [local.repo_all_widgets]
  })
  dashboard_name = "RepositoryDashboard${title(var.environment)}"
}