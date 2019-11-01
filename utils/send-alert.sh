#!/bin/bash

if [ "$CODEBUILD_BUILD_SUCCEEDING" == "0" ]; then 
  PREVIOUS_BUILD=$(aws codebuild list-builds-for-project --project-name prm-secscan-prm-infra-plan --query 'ids[0]' --output text)
  PREVIOUS_STATUS=$(aws codebuild batch-get-builds --ids $PREVIOUS_BUILD --query 'builds[0].buildStatus' --output text)
  if [ "$PREVIOUS_STATUS" == "SUCCEEDED" ]; then
    SLACKURL=https://hooks.slack.com/services/$(aws ssm get-parameter --name "/NHS/${ENVIRONMENT}-${ACCOUNT_ID}/tf/secscan/slack_url" --with-decryption --query "Parameter.Value" --output text)
    curl -X POST -H 'Content-type: application/json' --data '{"link_names":1,"text":"@channel a security alert has been detected in prm-infra"}' ${SLACKURL}
  fi
fi
