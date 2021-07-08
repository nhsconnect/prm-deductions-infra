import { rotateApiKeys } from "./rotate-api-keys";

rotateApiKeys(true).catch(e => {
  throw e
});
