data "aws_ssm_parameter" "mesh_forwarder_nems_observability_queue" {
  name = "/repo/${var.environment}/output/mesh-forwarder/nems-events-observability-queue"
}

data "aws_ssm_parameter" "incoming_nems_events_queue_name"{
  name = "/repo/${var.environment}/output/nems-event-processor/incoming-nems-events-queue-name"
}

data "aws_ssm_parameter" "nems_events_dlq_name"{
  name = "/repo/${var.environment}/output/nems-event-processor/dlq-name"
}

data "aws_ssm_parameter" "nems_undhandled_queue_name"{
  name = "/repo/${var.environment}/output/nems-event-processor/unhandled_events_queue_name"
}

data "aws_ssm_parameter" "nems_cluster_name"{
  name = "/repo/${var.environment}/output/nems-event-processor/nems-event-processor-ecs-cluster-name"
}

data "aws_ssm_parameter" "suspensions_observability_queue_name"{
  name = "/repo/${var.environment}/output/nems-event-processor/suspensions-observability-queue-name"
}

data "aws_ssm_parameter" "suspensions-queue-name"{
  name = "/repo/${var.environment}/output/suspension-service/suspensions-queue-name"
}

data "aws_ssm_parameter" "suspension-service-ecs-cluster-name"{
  name = "/repo/${var.environment}/output/suspension-service/suspension-service-ecs-cluster-name"
}
data "aws_ssm_parameter" "not-suspended-observability-queue-name"{
  name = "/repo/${var.environment}/output/suspension-service/not-suspended-observability-queue-name"
}
data "aws_ssm_parameter" "nems_events_observability_queue"{
  name = "/repo/${var.environment}/output/mesh-forwarder/nems-events-observability-queue"
}

data "aws_ssm_parameter" "mesh_forwarder_ecs_cluster_name"{
  name = "/repo/${var.environment}/output/mesh-forwarder/mesh-forwarder-ecs-cluster-name"
}





