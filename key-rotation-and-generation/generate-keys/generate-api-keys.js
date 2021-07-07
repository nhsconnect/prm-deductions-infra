import { generateApiKey, getParam, getParamsByPath, deleteApiKey } from "../aws-clients/ssm-client"
import { convertStringListToArray,convertUserListToUserListParamArray } from "../helpers";
import { restartServices } from "../restart-services/restart-services";

export const generateApiKeys = async (ssmPath, isService, nhsEnvironment) => {
  console.log('Starting key generation and deletion process')
  try {
    const expectedApiKeys = convertStringListToArray(await getParam(ssmPath))
    const actualApiKeys = await getParamsByPath(`/repo/${nhsEnvironment}/user-input/api-keys/`)

    if (!isService){
      const actualUserApiKeys = actualApiKeys.filter(apiKey => apiKey.includes("/api-key-user/"));
      const expectedUserApiKeys = convertUserListToUserListParamArray(expectedApiKeys, nhsEnvironment)
      await processKeysAndRestartService(expectedUserApiKeys, actualUserApiKeys)
    } else {
      const actualServiceApiKeys = actualApiKeys.filter(apiKey => !apiKey.includes("/api-key-user/"));
      await processKeysAndRestartService(expectedApiKeys, actualServiceApiKeys)
    }
  } catch (err) {
    console.log(err);
    throw err
  }
};

async function processKeysAndRestartService(expectedApiKeys, actualApiKeys) {
  const generatedKeys = await generateKeys(expectedApiKeys, actualApiKeys)
  const deletedKeys = await deleteKeys(expectedApiKeys, actualApiKeys)
  await restartServices(generatedKeys.concat(deletedKeys));
}

async function generateKeys(expectedApiKeys, actualApiKeys) {
  const generatedApiKeys = []
  for (const expectedKey of expectedApiKeys) {
    if (!actualApiKeys.includes(expectedKey)) {
      await generateApiKey(expectedKey);
      generatedApiKeys.push(expectedKey)
    }
  }
  console.log(`Total keys generated ${generatedApiKeys.length}`)
  return generatedApiKeys;
}

async function deleteKeys(expectedApiKeys, actualApiKeys) {
  const deletedApiKeys = []
  for (const actualKey of actualApiKeys) {
    if (!expectedApiKeys.includes(actualKey)) {
      await deleteApiKey(actualKey);
      deletedApiKeys.push(actualKey)
    }
  }
  console.log(`Total keys deleted ${deletedApiKeys.length}`)
  return deletedApiKeys;
}
