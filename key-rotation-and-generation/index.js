import { generateParam, getParam} from "./ssm-client";
import { initializeConfig } from "./config";
import { convertStringListToArray } from "./helpers";
import { restartServices } from "./restart-services";

export const generateApiKeys = async () => {
  const { nhsEnvironment } = initializeConfig();
  try {
    const ssmPath = `/repo/${nhsEnvironment}/user-input/service-api-keys`;
    const apiKeysString = await getParam(ssmPath);
    const apiKeysArray = convertStringListToArray(apiKeysString);
    let generatedApiKeys = []
    for (const apiKey of apiKeysArray) {
      const apiKeyValue = await getParam(apiKey);
      if (!apiKeyValue) {
        await generateParam(apiKey);
        generatedApiKeys.push(apiKey)
      }
    };
    await restartServices(generatedApiKeys);
  } catch (err) {
    throw err;
  }
};

generateApiKeys().catch(err => console.log(err));