import {initializeConfig} from "./config";

export const convertStringListToArray = (apiKeysString) => {
  if (!apiKeysString) {
    throw new Error('Unable to retrieve list of api keys');
  } else {
    return apiKeysString.split(',');
  }
}

const nhsEnvironment  = 'nhs-environment'

export const convertUserListToUserListParamArray = (userApiKeys) => {
  if (userApiKeys.length === 0) {
    throw new Error('Message');
  } else {
    const paramList = []
    for (const apiKey of userApiKeys){
      addApiKeyToParamList(apiKey, paramList);
    }
    return paramList;
  }

  function addApiKeyToParamList(apiKey, paramList) {
    const apiKeyGpToRepoPath = `/repo/${nhsEnvironment}/user-input/api-keys/gp-to-repo/${apiKey}`
    const apiKeyRepoTpGpPath = `/repo/${nhsEnvironment}/user-input/api-keys/repo-to-gp/${apiKey}`
    const apiKeyEhrRepoPath = `/repo/${nhsEnvironment}/user-input/api-keys/ehr-repo/${apiKey}`
    const apiKeyGp2GpAdaptorPath = `/repo/${nhsEnvironment}/user-input/api-keys/gp2gp-adaptor/${apiKey}`

    paramList.push(apiKeyGpToRepoPath);
    paramList.push(apiKeyRepoTpGpPath);
    paramList.push(apiKeyEhrRepoPath);
    paramList.push(apiKeyGp2GpAdaptorPath);
  }
}
