import { when } from "jest-when";
import { generateApiKeys } from "../generate-api-keys";
import { deleteApiKey, generateApiKey, getParam, getParamsByPath } from "../../aws-clients/ssm-client";
import { convertStringListToArray } from "../../helpers";
import { restartServices } from "../../restart-services/restart-services";

jest.mock('../../aws-clients/ssm-client');
jest.mock('../../helpers')
jest.mock('../../restart-services/restart-services');

describe('generateApiKeys', () => {
  const apiKeysStringList = '/repo/env/api-keys/key,/repo/env/api-keys/key-1,/repo/env/api-keys/key-2';
  const ssmPath = `/repo/nhs-environment/user-input/service-api-keys`


  beforeEach(() => {
    when(getParam)
      .calledWith('/repo/not-found/user-input/service-api-keys')
      .mockResolvedValue(null)
      .calledWith('/repo/nhs-environment/user-input/service-api-keys')
      .mockResolvedValue(apiKeysStringList)
  })

  afterEach(() => jest.resetAllMocks())

  it('should not create new ssm parameter for api keys that already exist in ssm', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key','/repo/env/api-keys/key-1']);

    when(getParamsByPath)
      .calledWith('/repo/nhs-environment/user-input/api-keys/')
      .mockResolvedValue(['/repo/env/api-keys/key', '/repo/env/api-keys/key-1'])

    await generateApiKeys(ssmPath, true, 'nhs-environment');

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList);

    expect(generateApiKey).not.toHaveBeenCalled();
    expect(restartServices).toHaveBeenCalledWith([]);
  });

  it('should create new ssm parameter for api key if it is not found', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key','/repo/env/api-keys/key-1','/repo/env/api-keys/key-2'])

    when(getParamsByPath)
      .calledWith('/repo/nhs-environment/user-input/api-keys/')
      .mockResolvedValue(['/repo/env/api-keys/key', '/repo/env/api-keys/key-1'])

    await generateApiKeys(ssmPath, true, 'nhs-environment');

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList);
    expect(generateApiKey).toHaveBeenCalledWith('/repo/env/api-keys/key-2');
    expect(restartServices).toHaveBeenCalledWith(['/repo/env/api-keys/key-2']);
  });

  it('should delete ssm parameter for api key not expected', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key', '/repo/env/api-keys/key-1'])

    when(getParamsByPath)
      .calledWith('/repo/nhs-environment/user-input/api-keys/')
      .mockResolvedValue(['/repo/env/api-keys/key', '/repo/env/api-keys/key-1', '/repo/env/api-keys/unexpected-key'])

    await generateApiKeys(ssmPath, true, 'nhs-environment')

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList)
    expect(generateApiKey).not.toHaveBeenCalled()
    expect(deleteApiKey).toHaveBeenCalledWith('/repo/env/api-keys/unexpected-key')
    expect(restartServices).toHaveBeenCalledWith(['/repo/env/api-keys/unexpected-key'])
  })

  it('should both delete and generate api keys', async () => {
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key', '/repo/env/api-keys/actual-key'])

    when(getParamsByPath)
      .calledWith('/repo/nhs-environment/user-input/api-keys/')
      .mockResolvedValue(['/repo/env/api-keys/key', '/repo/env/api-keys/unexpected-key'])

    await generateApiKeys(ssmPath, true, 'nhs-environment')

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(apiKeysStringList)
    expect(generateApiKey).toHaveBeenCalledWith('/repo/env/api-keys/actual-key')
    expect(deleteApiKey).toHaveBeenCalledWith('/repo/env/api-keys/unexpected-key')
    expect(restartServices).toHaveBeenCalledWith(['/repo/env/api-keys/actual-key', '/repo/env/api-keys/unexpected-key'])
  })

  it('should not process user api keys', async () => {
    const userApiKey = '/repo/env/api-keys/api-key-user/joe.pesci'
    convertStringListToArray.mockReturnValueOnce(['/repo/env/api-keys/key', '/repo/env/api-keys/actual-key'])

    when(getParamsByPath)
      .calledWith('/repo/nhs-environment/user-input/api-keys/')
      .mockResolvedValue(['/repo/env/api-keys/key', '/repo/env/api-keys/unexpected-key', userApiKey])

    await generateApiKeys(ssmPath, true, 'nhs-environment')

    expect(generateApiKey).not.toHaveBeenCalledWith(userApiKey)
    expect(deleteApiKey).not.toHaveBeenCalledWith(userApiKey)
    expect(restartServices).toHaveBeenCalledWith(expect.not.arrayContaining([userApiKey]))
  })

  it('should throw an error when cannot get list of api keys from ssm', async () => {
    convertStringListToArray.mockImplementationOnce(() => {
      throw new Error('some-error')
    });

    const wrongSsmPath = `/repo/not-found/user-input/service-api-keys`

    await expect(generateApiKeys(wrongSsmPath, true, 'not-found'))
        .rejects.toEqual(new Error("some-error"))

    expect(getParam).toHaveBeenCalledWith('/repo/not-found/user-input/service-api-keys')
    expect(convertStringListToArray).toHaveBeenCalledWith(null);
    expect(generateApiKey).not.toHaveBeenCalled();
    expect(restartServices).not.toHaveBeenCalled();
  });
});

