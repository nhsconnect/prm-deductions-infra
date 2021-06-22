import { ECSClient, UpdateServiceCommand } from "@aws-sdk/client-ecs";
import {initializeConfig} from "./config";

const client = new ECSClient({ region: "eu-west-2" });

export const restartECS = async (serviceName) => {
  const command = new UpdateServiceCommand({ forceNewDeployment: true, service: `${initializeConfig().nhsEnvironment}-${serviceName}-service`});
  await client.send(command);
}