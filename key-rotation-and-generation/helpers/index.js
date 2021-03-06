

export const convertStringListToArray = (apiKeysString) => {
  if (!apiKeysString) {
    throw new Error('Unable to retrieve list of api keys');
  } else {
    return apiKeysString.split(',');
  }
}

export const convertUserListToUserListParamArray = (userApiKeys, nhsEnvironment) => {
  if (userApiKeys.length === 0) {
    throw new Error('Expected user api key list is empty');
  } else {
    const paramList = []
    for (const apiKey of userApiKeys){
      addApiKeyToParamList(apiKey, paramList);
    }
    return paramList;
  }

  function addApiKeyToParamList(apiKey, paramList) {
    const apiKeyGpToRepoPath = `/repo/${nhsEnvironment}/user-input/api-keys/gp-to-repo/api-key-user/${apiKey}`
    const apiKeyRepoTpGpPath = `/repo/${nhsEnvironment}/user-input/api-keys/repo-to-gp/api-key-user/${apiKey}`
    const apiKeyEhrRepoPath = `/repo/${nhsEnvironment}/user-input/api-keys/ehr-repo/api-key-user/${apiKey}`
    const apiKeyGp2GpAdaptorPath = `/repo/${nhsEnvironment}/user-input/api-keys/gp2gp-adaptor/api-key-user/${apiKey}`

    paramList.push(apiKeyGpToRepoPath);
    paramList.push(apiKeyRepoTpGpPath);
    paramList.push(apiKeyEhrRepoPath);
    paramList.push(apiKeyGp2GpAdaptorPath);
  }
}
