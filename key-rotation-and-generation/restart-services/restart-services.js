import { initializeConfig } from "../config";
import { restartECS } from "../aws-clients/ecs-client";


export const restartServices = async (apiKeys) => {
  let servicesToRestart = []
  for (const key of apiKeys) {
    const services = key.split(`/repo/${initializeConfig().nhsEnvironment}/user-input/api-keys/`)[1];
    const [ producerService, consumerService ] = services.split('/');
    addToServicesToRestart(servicesToRestart, producerService);
    addToServicesToRestart(servicesToRestart, consumerService);
  }

  for (const service of servicesToRestart) {
    await restartECS(service);
  }
};

function addToServicesToRestart(servicesToRestart, serviceName) {
  if (!servicesToRestart.includes(serviceName) && serviceName !== 'e2e-test') {
    servicesToRestart.push(serviceName);
  }
}