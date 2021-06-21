import { generateApiKeys } from "../index";
import { getParam } from "../ssm-client";
import { initializeConfig } from "../config";

jest.mock('../ssm-client');
jest.mock('../config');

describe('Key Rotation and Generation', () => {
  it('generateApiKeys should call getParam', async () => {
    initializeConfig.mockReturnValueOnce({ nhsEnvironment: 'nhs-environment' });
    await generateApiKeys();

    expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/service-api-keys')
  });
})

