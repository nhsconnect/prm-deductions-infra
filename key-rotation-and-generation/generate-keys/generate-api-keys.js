import { generateApiKey, getParam } from "../aws-clients/ssm-client";
import { convertStringListToArray,convertUserListToUserListParamArray } from "../helpers";
import { restartServices } from "../restart-services/restart-services";

export const generateApiKeys = async (ssmPath, isService) => {

  async function generate(apiKeysArray) {
    let generatedApiKeys = []
    for (const apiKey of apiKeysArray) {
      const apiKeyValue = await getParam(apiKey);
      if (!apiKeyValue) {
        await generateApiKey(apiKey);
        generatedApiKeys.push(apiKey)
      }
    }
    return generatedApiKeys
  }

  try {
    const apiKeysString = await getParam(ssmPath);
    const apiKeysArray = convertStringListToArray(apiKeysString)
    let restartServiceList=[]
    if(!isService){
      restartServiceList = generate(convertUserListToUserListParamArray(apiKeysArray))
      await restartServices(restartServiceList);
    }else {
      restartServiceList = generate(apiKeysArray)
      await restartServices(restartServiceList);
    }
  } catch (err) {
    console.log(err);
  }
};