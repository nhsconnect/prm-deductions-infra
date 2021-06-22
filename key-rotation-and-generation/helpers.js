export const convertStringListToArray = (apiKeysString) => {
  if (!apiKeysString) {
    throw new Error('Unable to retrieve list of api keys');
  } else {
    return apiKeysString.split(',');
  }
}