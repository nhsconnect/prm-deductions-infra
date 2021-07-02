import { generateApiKey, getParam } from "../aws-clients/ssm-client";
import { convertStringListToArray,convertUserListToUserListParamArray } from "../helpers";
import { restartServices } from "../restart-services/restart-services";

export const generateApiKeys = async (ssmPath, isService, nhsEnvironment) => {
  try {
    const apiKeysString = await getParam(ssmPath);
    const apiKeysArray = convertStringListToArray(apiKeysString)
    let restartServiceList;
    if (!isService){
      restartServiceList = await generate(convertUserListToUserListParamArray(apiKeysArray, nhsEnvironment))
      await restartServices(restartServiceList);
    } else {
      restartServiceList = await generate(apiKeysArray)
      await restartServices(restartServiceList);
    }
  } catch (err) {
    console.log(err);
    throw err
  }
};

async function generate(apiKeysArray) {
  let generatedApiKeys = []
  for (const apiKey of apiKeysArray) {
    const apiKeyValue = await getParam(apiKey);
    if (!apiKeyValue) {
      await generateApiKey(apiKey);
      generatedApiKeys.push(apiKey)
    }
  }
  return generatedApiKeys;
}