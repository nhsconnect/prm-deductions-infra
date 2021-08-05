import { convertUserListToUserListParamArray } from "../";
import { when } from "jest-when";
import { initializeConfig } from "../../config";

jest.mock("../../config");

describe("convertUserListToUserListParamArray", () => {
  it("should create user api key for each service in a non strict environment", () => {
    when(initializeConfig).calledWith().mockReturnValue({
      nhsEnvironment: "dev",
      isStrictEnvironment: false,
    });
    const result = convertUserListToUserListParamArray([
      "michael.stone",
      "will.smith",
    ]);

    expect(result).toEqual(
      expect.arrayContaining([
        "/repo/dev/user-input/api-keys/gp-to-repo/api-key-user/michael.stone",
        "/repo/dev/user-input/api-keys/repo-to-gp/api-key-user/michael.stone",
        "/repo/dev/user-input/api-keys/ehr-repo/api-key-user/michael.stone",
        "/repo/dev/user-input/api-keys/gp2gp-adaptor/api-key-user/michael.stone",
        "/repo/dev/user-input/api-keys/gp-to-repo/api-key-user/will.smith",
        "/repo/dev/user-input/api-keys/repo-to-gp/api-key-user/will.smith",
        "/repo/dev/user-input/api-keys/ehr-repo/api-key-user/will.smith",
        "/repo/dev/user-input/api-keys/gp2gp-adaptor/api-key-user/will.smith",
      ])
    );
  });

  it("should create user api key for ehr-repo and gp-to-repo services in a strict environment", () => {
    when(initializeConfig).calledWith().mockReturnValue({
      nhsEnvironment: "pre-prod",
      isStrictEnvironment: true,
    });
    const result = convertUserListToUserListParamArray([
      "michael.stone",
      "will.smith",
    ]);

    expect(result).toEqual(
      expect.arrayContaining([
        "/repo/pre-prod/user-input/api-keys/gp-to-repo/api-key-user/michael.stone",
        "/repo/pre-prod/user-input/api-keys/ehr-repo/api-key-user/michael.stone",
        "/repo/pre-prod/user-input/api-keys/gp-to-repo/api-key-user/will.smith",
        "/repo/pre-prod/user-input/api-keys/ehr-repo/api-key-user/will.smith",
      ])
    );

    expect(result).toEqual(
      expect.not.arrayContaining([
        "/repo/dev/user-input/api-keys/repo-to-gp/api-key-user/michael.stone",
        "/repo/dev/user-input/api-keys/gp2gp-adaptor/api-key-user/michael.stone",
        "/repo/dev/user-input/api-keys/repo-to-gp/api-key-user/will.smith",
        "/repo/dev/user-input/api-keys/gp2gp-adaptor/api-key-user/will.smith",
      ])
    );
  });

  it("should throw error if expected api key list is empty", () => {
    expect(() => convertUserListToUserListParamArray([])).toThrow(
      "Expected user api key list is empty"
    );
  });
});
