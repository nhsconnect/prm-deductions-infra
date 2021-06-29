import { initializeConfig } from "../config";
import { getParamsByPath, getRotateApiKeyTag } from "../aws-clients/ssm-client";

export const rotateApiKeys = async () => {
  const { nhsEnvironment } = initializeConfig();
  try {
    const apiKeysArray = await getParamsByPath(`/repo/${nhsEnvironment}/user-input/api-keys/`)
    for (const apiKey of apiKeysArray) {
      await getRotateApiKeyTag(apiKey);
    }
  } catch (e) {
    console.log(e);
  }
};