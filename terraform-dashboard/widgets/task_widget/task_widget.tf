variable "component" {
}

variable "environment" {
}

variable "metric_type" {
  validation {
    condition     = contains(["memory", "cpu"], var.metric_type)
    error_message = "The metric_type value must be \"memory\" or \"cpu\"."
  }
}

variable "region" {
  default = "eu-west-2"
}

variable "title" {
  description = "Widget title"
}

locals {
  container_insights_log_group = "/aws/ecs/containerinsights/${var.environment}-${var.component}-ecs-cluster/performance"

  log_query = <<EOF
fields 
  ${title(var.metric_type)}Utilized / ${title(var.metric_type)}Reserved * 100 as Percent,
  (AvailabilityZone like "${var.region}a") as is_A,
  (AvailabilityZone like "${var.region}b") as is_B
| filter
    (Type = "Task")
| stats 
    sum(Percent * is_A) as A, 
    sum(Percent * is_B) as B
    by bin(2m) as period
| sort
    period desc
EOF

  widget = {
    type = "log"
    properties = {
      query = "SOURCE '${local.container_insights_log_group}' | ${local.log_query}"
      region = var.region
      title = var.title
      view = "timeSeries"
      stacked = false
    }
  }
}

output "widget" {
  value = local.widget
}