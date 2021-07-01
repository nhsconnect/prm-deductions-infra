import { generateApiKey, getParam } from "../aws-clients/ssm-client";
import { initializeConfig } from "../config";
import { convertStringListToArray } from "../helpers";
import { restartServices } from "../restart-services/restart-services";

export const generateApiKeys = async (ssmPath, isService) => {

  try {
    const apiKeysString = await getParam(ssmPath);
    const apiKeysArray = convertStringListToArray(apiKeysString)
    let generatedApiKeys = []
    for (const apiKey of apiKeysArray) {
      const apiKeyValue = await getParam(apiKey);
      if (!apiKeyValue) {
        await generateApiKey(apiKey);
        generatedApiKeys.push(apiKey)
      }
    }
    await restartServices(generatedApiKeys);
  } catch (err) {
    console.log(err);
  }
};