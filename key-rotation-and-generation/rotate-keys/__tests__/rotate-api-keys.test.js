import { rotateApiKeys } from "../rotate-api-keys";
import {getParamsByPath, getRotateApiKeyTag} from "../../aws-clients/ssm-client";
import { initializeConfig } from "../../config";

jest.mock('../../aws-clients/ssm-client');
jest.mock('../../config');

describe('rotateApiKeys', () => {
  initializeConfig.mockReturnValue({ nhsEnvironment: 'env'});

  it('should get tags for each api key parameter', async () => {
    getParamsByPath.mockResolvedValue(['/repo/env/api-keys/key','/repo/env/api-keys/key-1']);
    await rotateApiKeys();

    expect(getParamsByPath).toHaveBeenCalledWith('/repo/env/user-input/api-keys/');
    expect(getRotateApiKeyTag).toHaveBeenCalledTimes(2);
  });
});