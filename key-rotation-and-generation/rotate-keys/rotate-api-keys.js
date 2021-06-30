import { initializeConfig } from "../config";
import { getParamsByPath, getRotateApiKeyTag, removeRotateApiKeyTag, rotateApiKey } from "../aws-clients/ssm-client";
import { restartServices } from "../restart-services/restart-services";

export const rotateApiKeys = async () => {
  const { nhsEnvironment } = initializeConfig();
  try {
    const apiKeysArray = await getParamsByPath(`/repo/${nhsEnvironment}/user-input/api-keys/`)
    let rotatedApiKeys = [];
    for (const apiKey of apiKeysArray) {
      const rotateApiKeyTag = await getRotateApiKeyTag(apiKey);
      if (rotateApiKeyTag) {
        await rotateApiKey(apiKey);
        await removeRotateApiKeyTag(apiKey)
        rotatedApiKeys.push(apiKey);
      }
    }
    await restartServices(rotatedApiKeys);
  } catch (e) {
    console.log(e);
  }
};