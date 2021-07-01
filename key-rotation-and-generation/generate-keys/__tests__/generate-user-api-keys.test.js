import {initializeConfig} from "../../config";
import {convertStringListToArray} from "../../helpers";
import {generateApiKeys} from "../generate-api-keys";
import {generateApiKey, getParam} from "../../aws-clients/ssm-client";
import {restartServices} from "../../restart-services/restart-services";
import {when} from "jest-when";

jest.mock('../../aws-clients/ssm-client');
jest.mock('../../config');
jest.mock('../../helpers');
jest.mock('../../restart-services/restart-services');

describe('generateUserApiKeys', () => {
    initializeConfig.mockReturnValue({nhsEnvironment: 'nhs-environment'});
    const apiKeysStringList = 'al.pacino1,rob.deniro,lady.gaga,joe.pesci';
    const ssmPath = `/repo/nhs-environment/user-input/repo-dev-list`

    when(getParam)
        .calledWith('/repo/nhs-environment/user-input/repo-dev-list')
        .mockResolvedValue('al.pacino1,rob.deniro,lady.gaga,joe.pesci')


    it('should not create new user-api-key ssm parameter that already exist in ssm', async () => {
        await generateApiKeys(ssmPath, false);

        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/repo-dev-list')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/api-keys/repo-to-gp/al.pacino1')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/api-keys/repo-to-gp/lady.gaga')
        expect(generateApiKey).toHaveBeenCalled();
        expect(restartServices).toHaveBeenCalledWith([]);
    });
})
