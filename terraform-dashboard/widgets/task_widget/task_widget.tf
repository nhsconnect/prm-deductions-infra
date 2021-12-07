variable "component" {
  validation {
    condition     = alltrue([contains(keys(var.component), "name"), contains(keys(var.component), "title")])
    error_message = "The component must have \"name\", and \"title\" keys."
  }

  validation {
    condition     = contains(["memory", "cpu"], var.component.metric_type)
    error_message = "The component.metric_type value must be \"memory\" or \"cpu\"."
  }
}

variable "environment" {
}

variable "region" {
  default = "eu-west-2"
}

locals {
  container_insights_log_group = "/aws/ecs/containerinsights/${var.environment}-${var.component.name}-ecs-cluster/performance"

  log_query = <<EOF
fields
  ${title(var.component.metric_type)}Utilized / ${title(var.component.metric_type)}Reserved * 100 as Percent,
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
      query  = "SOURCE '${local.container_insights_log_group}' | ${local.log_query}"
      region = var.region
      title  = var.component.title
      view   = "timeSeries"
    }
  }
}

output "widget" {
  value = local.widget
}