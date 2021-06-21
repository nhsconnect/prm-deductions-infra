import { getParam } from "./ssm-client";
import { initializeConfig } from "./config";

export const generateApiKeys = async () => {
  const ssmPath = `/repo/${initializeConfig().nhsEnvironment}/user-input/service-api-keys`;
  await getParam(ssmPath);
}