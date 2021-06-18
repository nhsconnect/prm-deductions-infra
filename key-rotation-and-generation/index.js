const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");

const client = new SSMClient({ region: "eu-west-2" });

const getParam = async (parameterName) => {
  try {
    const command = new GetParameterCommand({ Name: parameterName });
    return await client.send(command);
  } catch (err) {
    console.log(err);
  }
};

module.exports = { getParam };