import randomstring from "randomstring";
import {
  GetParameterCommand,
  GetParametersByPathCommand,
  ListTagsForResourceCommand,
  PutParameterCommand,
  RemoveTagsFromResourceCommand,
  SSMClient
} from '@aws-sdk/client-ssm';

const client = new SSMClient({ region: "eu-west-2" });

export const getParam = async (parameterName) => {
  const command = new GetParameterCommand({ Name: parameterName });
  try {
    const ssmParameter = await client.send(command);
    return ssmParameter.Parameter.Value;
  } catch (err) {
    if(err.name === 'ParameterNotFound') {
      console.log(`ParameterNotFound - ${parameterName}`)
      return null;
    }
    throw err;
  }
};

export const getParamsByPath = async (ssmPath) => {
  const command = new GetParametersByPathCommand({ Path: ssmPath, Recursive: true });
  const response = await client.send(command);
  return response.Parameters.map(param => param.Name);
};

export const generateApiKey = async (parameterName) => {
  const keyValue = randomstring.generate();
  const command = new PutParameterCommand({ Name: parameterName, Type: 'SecureString', Value: keyValue });
  await client.send(command);

  console.log(`${parameterName} API Key has been generated`)
}

export const rotateApiKey = async (parameterName) => {
  const keyValue = randomstring.generate();
  const command = new PutParameterCommand({ Name: parameterName, Type: 'SecureString', Value: keyValue, Overwrite: true });
  await client.send(command);

  console.log(`${parameterName} API Key has been rotated`)
}

export const getRotateApiKeyTag = async (ssmPath) => {
  const command = new ListTagsForResourceCommand({ ResourceId: ssmPath, ResourceType: 'Parameter' });
  const response = await client.send(command);
  const rotateApiKeyTag = response.TagList.filter(tag => tag.Key === 'RotateApiKey');
  return rotateApiKeyTag.length !== 0;
};

export const removeRotateApiKeyTag = async (ssmPath) => {
  const command = new RemoveTagsFromResourceCommand({ ResourceId: ssmPath, ResourceType: 'Parameter', TagKeys: ['RotateApiKey'] });
  await client.send(command);
};