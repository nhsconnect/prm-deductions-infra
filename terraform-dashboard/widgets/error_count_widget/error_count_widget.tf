variable "component" {
}

variable "region" {
  default = "eu-west-2"
}

variable "title" {
  description = "Widget title"
}

locals {
  component_pascal_case = replace(title(var.component), "-", "")
  widget = {
    type = "metric"
    properties = {
      metrics = [
        [ local.component_pascal_case, "ErrorCountInLogs" ]
      ],
      region = var.region
      title = "${var.title} Error Count"
      view = "timeSeries"
      stat = "Average",
      period = 300,
      stacked = false
    }
  }
}

output "widget" {
  value = local.widget
}