import { restartServices } from "../restart-services";
import { restartECS } from "../../aws-clients/ecs-client";
import { initializeConfig } from "../../config";

jest.mock('../../aws-clients/ecs-client');
jest.mock('../../config');

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

  it('should call producer to be restarted for user api key rotation', async () => {
    const apiKeys = ['/repo/env/user-input/api-keys/fake-repo/other-fake-repo',
      '/repo/env/user-input/api-keys/fake-repo-1/api-key-user/al.pacino',
      '/repo/env/user-input/api-keys/fake-repo-1/api-key-user/rob.deniro',
      '/repo/env/user-input/api-keys/fake-repo-2/api-key-user/al.pacino']
    await restartServices(apiKeys)

    expect(restartECS).toHaveBeenCalledWith('fake-repo')
    expect(restartECS).toHaveBeenCalledWith('other-fake-repo')
    expect(restartECS).toHaveBeenCalledWith('fake-repo-1')
    expect(restartECS).toHaveBeenCalledWith('fake-repo-2')
    expect(restartECS).not.toHaveBeenCalledWith('api-key-user')
    expect(restartECS).toHaveBeenCalledTimes(4)
  });
})