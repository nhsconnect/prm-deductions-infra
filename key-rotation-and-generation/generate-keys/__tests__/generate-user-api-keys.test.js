import {generateApiKeys} from "../generate-api-keys";
import {generateApiKey, getParam} from "../../aws-clients/ssm-client";
import {restartServices} from "../../restart-services/restart-services";
import {when} from "jest-when";

jest.mock('../../aws-clients/ssm-client');
jest.mock('../../restart-services/restart-services');

describe('generateUserApiKeys', () => {
    const apiKeysStringList = 'al.pacino1,rob.deniro,lady.gaga,joe.pesci';
    const ssmPath = `/repo/nhs-environment/user-input/repo-dev-list`

    when(getParam)
        .calledWith('/repo/nhs-environment/user-input/repo-dev-list')
        .mockResolvedValue(apiKeysStringList)
        .calledWith('/repo/nhs-environment/user-input/empty-repo-dev-list')
        .mockResolvedValue(null)
        .calledWith('/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/al.pacino1')
        .mockResolvedValue(null)
        .calledWith('/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/joe.pesci')
        .mockResolvedValue('key123');


    it('should create new user-api-key ssm parameter for a key that does not exist', async () => {
        await generateApiKeys(ssmPath, false, 'nhs-environment');

        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/repo-dev-list')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/repo-to-gp/api-key-user/al.pacino1')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/rob.deniro')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/repo-to-gp/api-key-user/lady.gaga')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/repo-to-gp/api-key-user/joe.pesci')
        expect(generateApiKey).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/al.pacino1');
        expect(restartServices).toHaveBeenCalledWith(
            expect.arrayContaining(['/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/al.pacino1'])
        );
    });

    it('should not create new user-api-key ssm parameter for a key that already exists', async () => {
        await generateApiKeys(ssmPath, false, 'nhs-environment');

        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/repo-dev-list')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/repo-to-gp/api-key-user/al.pacino1')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/rob.deniro')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/repo-to-gp/api-key-user/lady.gaga')
        expect(getParam).toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/repo-to-gp/api-key-user/joe.pesci')
        expect(generateApiKey).not.toHaveBeenCalledWith('/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/joe.pesci');
        expect(restartServices).toHaveBeenCalledWith(
            expect.not.arrayContaining(['/repo/nhs-environment/user-input/api-keys/gp-to-repo/api-key-user/joe.pesci']));
    });

    it('should throw and error when ssm has no value', async () => {

        when(getParam)
            .calledWith('repo-dev-empty-list')
            .mockResolvedValue(null)

        await expect(generateApiKeys("repo-dev-empty-list", false, 'nhs-environment'))
            .rejects.toEqual(new Error("Unable to retrieve list of api keys"))

    })
})