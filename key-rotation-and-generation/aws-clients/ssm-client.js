import randomstring from "randomstring";
import {
  GetParameterCommand,
  GetParametersByPathCommand,
  ListTagsForResourceCommand,
  PutParameterCommand,
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

export const generateParam = async (parameterName) => {
  const keyValue = randomstring.generate();
  const command = new PutParameterCommand({ Name: parameterName, Type: 'SecureString', Value: keyValue });
  await client.send(command);

  console.log(`API Key generated for ${parameterName}`)
}

export const getParamsByPath = async (path) => {
  const command = new GetParametersByPathCommand({ Path: path, Recursive: true });
  const response = await client.send(command);
  return response.Parameters.map(param => param.Name);
};

export const getRotateApiKeyTag = async (path) => {
  const command = new ListTagsForResourceCommand({ ResourceId: path, ResourceType: 'Parameter' });
  const response = await client.send(command);
  const rotateApiKeyTag = response.TagList.filter(tag => tag.Key === 'RotateApiKey');
  return rotateApiKeyTag.length !== 0;
};