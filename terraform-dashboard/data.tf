data "aws_ssm_parameter" "mesh_forwarder_nems_observability_queue" {
  name = "/repo/${var.environment}/output/mesh-forwarder/nems-events-observability-queue"
}

