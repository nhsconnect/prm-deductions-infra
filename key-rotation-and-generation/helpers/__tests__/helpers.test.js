import {convertUserListToUserListParamArray} from "../"

describe('convertUserListToUserListParamArray', () => {

  it('should create user api key for each service', () => {
    const result = convertUserListToUserListParamArray(['michael.stone', 'will.smith'], 'dev')

    expect(result).toEqual(expect.arrayContaining([
      '/repo/dev/user-input/api-keys/gp-to-repo/api-key-user/michael.stone',
      '/repo/dev/user-input/api-keys/repo-to-gp/api-key-user/michael.stone',
      '/repo/dev/user-input/api-keys/ehr-repo/api-key-user/michael.stone',
      '/repo/dev/user-input/api-keys/gp2gp-adaptor/api-key-user/michael.stone',
      '/repo/dev/user-input/api-keys/gp-to-repo/api-key-user/will.smith',
      '/repo/dev/user-input/api-keys/repo-to-gp/api-key-user/will.smith',
      '/repo/dev/user-input/api-keys/ehr-repo/api-key-user/will.smith',
      '/repo/dev/user-input/api-keys/gp2gp-adaptor/api-key-user/will.smith',
    ]))
  })

  it('should throw error if expected api key list is empty', () => {
    expect(() => convertUserListToUserListParamArray([], 'dev')).toThrow('Expected user api key list is empty')
  })
})
