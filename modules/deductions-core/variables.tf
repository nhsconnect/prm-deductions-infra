variable "region" {
  type = string
  default = "eu-west-2"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "component_name" {
  type        = string
  default     = "deductions-core"
}

variable "ehr_deregistration_delay" {
  default = 30
}
