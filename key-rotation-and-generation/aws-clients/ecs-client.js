import { ECSClient, UpdateServiceCommand } from "@aws-sdk/client-ecs";
import { initializeConfig } from "../config";

const client = new ECSClient({ region: "eu-west-2" });

export const restartECS = async (serviceName) => {
  const service = `${initializeConfig().nhsEnvironment}-${serviceName}-service`
  const cluster = `${initializeConfig().nhsEnvironment}-${serviceName}-ecs-cluster`
  const command = new UpdateServiceCommand({ forceNewDeployment: true, service, cluster });
  console.log(`Restarting ECS For Cluster ${cluster}, Service: ${service}`);
  await client.send(command);
}