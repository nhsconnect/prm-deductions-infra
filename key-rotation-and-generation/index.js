import { generateParam, getParam} from "./ssm-client";
import { initializeConfig } from "./config";
import { convertStringListToArray } from "./helpers";

export const generateApiKeys = async () => {
  const { nhsEnvironment } = initializeConfig();
  try {
    const ssmPath = `/repo/${nhsEnvironment}/user-input/service-api-keys`;
    const apiKeysString = await getParam(ssmPath);
    const apiKeysArray = convertStringListToArray(apiKeysString);
    for (const apiKey of apiKeysArray) {
      const apiKeyValue = await getParam(apiKey);
      if (!apiKeyValue) {
        await generateParam(apiKey);
      }
    }
  } catch (err) {
    throw err;
  }
};

generateApiKeys().catch(() => {});