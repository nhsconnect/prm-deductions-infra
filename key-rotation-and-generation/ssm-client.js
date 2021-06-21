import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const client = new SSMClient({ region: "eu-west-2" });

export const getParam = async (parameterName) => {
  try {
    const command = new GetParameterCommand({ Name: parameterName });
    const ssmParameter = await client.send(command);
    return ssmParameter.Parameter.Value;
  } catch (err) {
    console.log(err);
  }
};