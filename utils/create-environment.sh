#! /bin/bash

unset_vars() {
    echo unset TF_VAR_ssh_public
}

unset_vars

ENV=$1
ACCOUNT_NUMBER=$2

export TF_VAR_ssh_public="$(aws ssm get-parameter --region='eu-west-2' --with-decryption --name  /NHS/$ENV-$ACCOUNT_NUMBER/tf/opentest/ec2_keypair | jq -r '.Parameter.Value')"

cd ../terraformscripts/$ENV-$ACCOUNT_NUMBER

cd ./network
terragrunt init --terragrunt-source-update
terragrunt validate
terragrunt apply --auto-approve
cd ../

cd ./opentest
terragrunt init --terragrunt-source-update
terragrunt validate
terragrunt apply --auto-approve
cd ../

cd ./apigw_lambda
terragrunt init --terragrunt-source-update
terragrunt validate
terragrunt apply --auto-approve
cd ../
