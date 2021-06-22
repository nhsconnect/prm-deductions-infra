import {restartServices} from "../restart-services";
import {restartECS} from "../ecs-client";
import { initializeConfig } from "../config";

jest.mock('../ecs-client');
jest.mock('../config');

describe('Restart services', () => {
  initializeConfig.mockReturnValue({ nhsEnvironment: 'env' });

  afterEach(() => {
    restartECS.mockRestore();
  })

  it('should call ecs client with each service from api key', async () => {
    const apiKeys = ['/repo/env/user-input/api-keys/fake-repo/other-fake-repo', '/repo/env/user-input/api-keys/fake-repo/test-repo']
    await restartServices(apiKeys)

    expect(restartECS).toHaveBeenCalledWith('fake-repo')
    expect(restartECS).toHaveBeenCalledWith('other-fake-repo')
    expect(restartECS).toHaveBeenCalledWith('test-repo')
    expect(restartECS).toHaveBeenCalledTimes(3)
  });

  it('should not call ecs service for api key e2e-test', async () => {
    const apiKeys = ['/repo/env/user-input/api-keys/fake-repo/e2e-test']
    await restartServices(apiKeys)

    expect(restartECS).toHaveBeenCalledWith('fake-repo')
    expect(restartECS).not.toHaveBeenCalledWith('e2e-test')
    expect(restartECS).toHaveBeenCalledTimes(1)
  });
})