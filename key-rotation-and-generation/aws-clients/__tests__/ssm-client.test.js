import {
  DeleteParameterCommand,
  GetParametersByPathCommand
} from '@aws-sdk/client-ssm'
import {deleteApiKey, getParamsByPath} from "../ssm-client"
import {ssmClient} from "../clients"
import {when} from "jest-when";

jest.mock('@aws-sdk/client-ssm')
jest.mock("../clients")

describe('ssm-client', () => {

  const ssmPath = "/path"

  describe('getParamsByPath', () => {
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

  describe('deleteApiKey', () => {

    it('should create command with name for DeleteParameterCommand and send to client', async () => {
      const parameterName = "parameterName"
      const mockCommand = {command: "DeleteParameter"}

      when(DeleteParameterCommand).calledWith({Name: parameterName}).mockReturnValue(mockCommand)

      await deleteApiKey(parameterName)

      expect(DeleteParameterCommand).toHaveBeenCalledWith({Name: parameterName})
      expect(ssmClient.send).toHaveBeenCalledWith(mockCommand)
    })
  })


})
