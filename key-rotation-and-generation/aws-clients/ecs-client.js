import {
  DescribeServicesCommand,
  ECSClient,
  UpdateServiceCommand
} from "@aws-sdk/client-ecs";
import { initializeConfig } from "../config";

const client = new ECSClient({ region: "eu-west-2" });

export const restartECS = async (serviceName) => {
  const service = `${initializeConfig().nhsEnvironment}-${serviceName}-service`
  const cluster = `${initializeConfig().nhsEnvironment}-${serviceName}-ecs-cluster`
  const updateServiceCommand = new UpdateServiceCommand({ forceNewDeployment: true, service, cluster });
  console.log(`Restarting ECS For Cluster ${cluster}, Service: ${service}`);
  await client.send(updateServiceCommand);

  await waitForServiceToRestart(service, cluster);
}

const waitForServiceToRestart = async (service, cluster) => {
  const describeServicesCommand = new DescribeServicesCommand({services: [service], cluster});

  const RETRY_COUNT = 10;
  const POLLING_INTERVAL = 20000;
  for (let i = 0; i < RETRY_COUNT; i++) {
    const response = await client.send(describeServicesCommand);
    const deployments = response.services[0].deployments;
    console.log('try: ', i, 'deployments status:', deployments.map(deployment => deployment.status))
    if (deployments.every(deployment => deployment.status !== 'ACTIVE')) {
      console.log('No ACTIVE deployments. Assuming restart finished')
      break;
    }
    await sleep(POLLING_INTERVAL);
  }
}

const sleep = ms => {
  return new Promise(resolve => setTimeout(resolve, ms));
};