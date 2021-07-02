import { generateApiKeys } from "./generate-api-keys";
import { initializeConfig } from "../config";

const { nhsEnvironment } = initializeConfig();

await generateApiKeys(`/repo/${nhsEnvironment}/user-input/service-api-keys`, true, nhsEnvironment);