locals {
#  repo_all_widgets = concat(
##  [module.health_widgets["re_registration_service"].widget]
#  )

#  re_registration_service = {
#    name  = "re-registration-service"
#    title = "Re-registration Service"
#  }

#  repo_task_widget_components  = [
#    local.re_registration_service
#  ]
#  repo_task_widget_types       = ["cpu", "memory"]
#  repo_task_widget_definitions = [
#  for pair in setproduct(local.repo_task_widget_types, local.repo_task_widget_components) : {
#    component = pair[1]
#    type      = pair[0]
#  }
#  ]
}

resource "aws_cloudwatch_dashboard" "repository_dashboard" {
  dashboard_body = jsonencode({
    widgets = []
  })
  dashboard_name = "RepositoryDashboard${title(var.environment)}"
}