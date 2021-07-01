import { when } from "jest-when";
import { generateApiKeys } from "../generate-api-keys";
import { getParam, generateApiKey } from "../../aws-clients/ssm-client";
import { initializeConfig } from "../../config";
import { convertStringListToArray } from "../../helpers";
import { restartServices } from "../../restart-services/restart-services";

jest.mock('../../aws-clients/ssm-client');
jest.mock('../../config');
jest.mock('../../helpers');
jest.mock('../../restart-services/restart-services');

describe('generateApiKeys', () => {
  initializeConfig.mockReturnValue({ nhsEnvironment: 'nhs-environment' });
  const apiKeysStringList = '/repo/env/api-keys/key,/repo/env/api-keys/key-1,/repo/env/api-keys/key-2';
  const ssmPath = `/repo/nhs-environment/user-input/service-api-keys`

  when(getParam)
    .calledWith('/repo/not-found/user-input/service-api-keys')
    .mockResolvedValue(null)
    .calledWith('/repo/nhs-environment/user-input/service-api-keys')
    .mockResolvedValue(apiKeysStringList)
    .calledWith('/repo/env/api-keys/key')
    .mockResolvedValue('key123')
    .calledWith('/repo/env/api-keys/key-1')
    .mockResolvedValue('key123')
    .calledWith('/repo/env/api-keys/key-2')
    .mockResolvedValue(null);

  afterEach(() => {
    convertStringListToArray.mockRestore();
    generateApiKey.mockRestore();
    restartServices.mockRestore();
  })

  it('should not create new ssm parameter for api keys that already exist in ssm', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key','/repo/env/api-keys/key-1']);

    await generateApiKeys(ssmPath, true);

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList);
    expect(getParam).toHaveBeenCalledWith('/repo/env/api-keys/key')
    expect(getParam).toHaveBeenCalledWith('/repo/env/api-keys/key-1')
    expect(generateApiKey).not.toHaveBeenCalled();
    expect(restartServices).toHaveBeenCalledWith([]);
  });

  it('should create new ssm parameter for api key if it is not found', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key','/repo/env/api-keys/key-1','/repo/env/api-keys/key-2'])

    await generateApiKeys(ssmPath, true);

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList);
    expect(generateApiKey).toHaveBeenCalledWith('/repo/env/api-keys/key-2');
    expect(restartServices).toHaveBeenCalledWith(['/repo/env/api-keys/key-2']);
  });

  it('should throw an error when cannot get list of api keys from ssm', async () => {
    initializeConfig.mockReturnValueOnce({ nhsEnvironment: 'not-found' });
    convertStringListToArray.mockImplementationOnce(() => {
      throw new Error('some-error')
    });

    const wrongSsmPath = `/repo/not-found/user-input/service-api-keys`

    await generateApiKeys(wrongSsmPath, true);

    expect(getParam).toHaveBeenCalledWith('/repo/not-found/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(null);
    expect(generateApiKey).not.toHaveBeenCalled();
    expect(restartServices).not.toHaveBeenCalled();
  });
});

