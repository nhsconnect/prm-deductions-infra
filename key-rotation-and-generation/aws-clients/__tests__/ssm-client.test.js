import {
  GetParametersByPathCommand,
} from '@aws-sdk/client-ssm';
import {getParamsByPath} from "../ssm-client"
import {ssmClient} from "../clients"
import {when} from "jest-when";

jest.mock('@aws-sdk/client-ssm')
jest.mock("../clients")

describe('ssm-client', () => {

  const ssmPath = "/path"

  it('should getParameters until NextToken is undefined', async () => {

    const mockCommand = {command: "firstCommand"}
    const mockSecondCommand = {command: "secondCommand"}

    const mockResponse = {NextToken: "NextTokenPresent", Parameters: [{Name: "a"}, {Name: "b"}, {Name: "c"}]}
    const mockSecondResponse = {NextToken: undefined, Parameters: [{Name: "d"}, {Name: "e"}, {Name: "f"}]}

    when(GetParametersByPathCommand)
      .calledWith({ Path: ssmPath, Recursive: true }).mockReturnValue(mockCommand)
      .calledWith({ Path: ssmPath, Recursive: true, NextToken: "NextTokenPresent" }).mockReturnValue(mockSecondCommand)
    when(ssmClient.send)
      .calledWith(mockCommand).mockResolvedValue(mockResponse)
      .calledWith(mockSecondCommand).mockResolvedValue(mockSecondResponse)

    const result = await getParamsByPath(ssmPath)
    expect(GetParametersByPathCommand).toHaveBeenCalledWith({ Path: ssmPath, Recursive: true })
    expect(GetParametersByPathCommand).toHaveBeenCalledWith({ Path: ssmPath, Recursive: true, NextToken: "NextTokenPresent" })
    expect(ssmClient.send).toBeCalledTimes(2)
    expect(result).toEqual(["a", "b", "c", "d", "e", "f"])
  })
})
