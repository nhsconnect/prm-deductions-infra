import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const client = new SSMClient({ region: "eu-west-2" });

export const getParam = async (parameterName) => {
  const command = new GetParameterCommand({ Name: parameterName });
  try {
    const ssmParameter = await client.send(command);
    return ssmParameter.Parameter.Value;
  } catch (err) {
    if(err.name === 'ParameterNotFound') {
      return null;
    }
    throw err;
  }
};

export const generateParam = async () => {}