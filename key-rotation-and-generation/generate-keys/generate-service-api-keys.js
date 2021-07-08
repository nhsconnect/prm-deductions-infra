import { generateApiKeys } from "./generate-api-keys";
import { initializeConfig } from "../config";

const { nhsEnvironment } = initializeConfig();

generateApiKeys(`/repo/${nhsEnvironment}/user-input/external/service-api-keys`, true, nhsEnvironment)
  .catch(() => {
    process.exit(1)
  });
