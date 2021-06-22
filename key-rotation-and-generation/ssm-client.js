import randomstring from "randomstring";
import { SSMClient, GetParameterCommand, PutParameterCommand } from '@aws-sdk/client-ssm';

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