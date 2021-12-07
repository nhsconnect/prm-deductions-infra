variable "component" {
}

variable "environment" {
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
        [ local.component_pascal_case, "Health", "Environment", var.environment ]
      ],
      region = var.region
      title = "${var.title} Health"
      view = "timeSeries"
      stat = "Average"
    }
  }
}

output "widget" {
  value = local.widget
}