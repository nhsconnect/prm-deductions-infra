import { when } from "jest-when";
import { generateApiKeys } from "../index";
import { getParam, generateParam } from "../ssm-client";
import { initializeConfig } from "../config";
import { convertStringListToArray } from "../helpers";

jest.mock('../ssm-client');
jest.mock('../config');
jest.mock('../helpers');

describe('Key Rotation and Generation - generateApiKeys', () => {
  initializeConfig.mockReturnValue({ nhsEnvironment: 'nhs-environment' });
  const apiKeysStringList = '/repo/env/api-keys/key,/repo/env/api-keys/key-1,/repo/env/api-keys/key-2';

  when(getParam)
    .calledWith('/repo/not-found/user-input/service-api-keys')
    .mockImplementationOnce(() => {
      throw new Error('cannot find list of api keys')
    })
    .calledWith('/repo/nhs-environment/user-input/service-api-keys')
    .mockResolvedValue(apiKeysStringList)
    .calledWith('/repo/env/api-keys/key')
    .mockResolvedValue('key123')
    .calledWith('/repo/env/api-keys/key-1')
    .mockResolvedValue('key123')
    .calledWith('/repo/env/api-keys/key-2')
    .mockResolvedValue(null);

  it('should not create new ssm parameter for api keys that already exist in ssm', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key','/repo/env/api-keys/key-1']);

    await generateApiKeys();

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList);
    expect(getParam).toHaveBeenCalledWith('/repo/env/api-keys/key')
    expect(getParam).toHaveBeenCalledWith('/repo/env/api-keys/key-1')
    expect(generateParam).not.toHaveBeenCalled();
  });

  it('should create new ssm parameter for api key if it is not found', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key','/repo/env/api-keys/key-1','/repo/env/api-keys/key-2'])

    await generateApiKeys();

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList);
    expect(generateParam).toHaveBeenCalledWith('/repo/env/api-keys/key-2');
  });

  it('should throw an error when cannot get list of api keys from ssm', async () => {
    initializeConfig.mockReturnValueOnce({ nhsEnvironment: 'not-found' });

    await expect(generateApiKeys()).rejects.toThrowError('cannot find list of api keys');
  });

})

