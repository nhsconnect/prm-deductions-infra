import { generateApiKeys } from "./generate-api-keys";
import { initializeConfig } from "../config";

const { nhsEnvironment } = initializeConfig();

generateApiKeys(`/repo/${nhsEnvironment}/user-input/repo-dev-list`, false, nhsEnvironment);