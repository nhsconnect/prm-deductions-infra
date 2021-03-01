# Infrastructure for the PRM Deductions Application

[Dojo](https://github.com/kudulab/dojo) docker image with tools needed to deploy infrastructure in scope of deductions team.

Tested and released images are published to dockerhub as [nhsdev/deductions-infra-dojo](https://hub.docker.com/r/nhsdev/deductions-infra-dojo)

## Usage
1. Setup docker.
2. Install [Dojo](https://github.com/kudulab/dojo) binary.
3. Provide a Dojofile at the root of the project:
```
DOJO_DOCKER_IMAGE="nhsdev/deductions-infra-dojo:<commit>"
```
4. Create and enter the container by running `dojo` at the root of project.

By default, current directory in docker container is `/dojo/work`.

## Access to AWS

In order to get sufficient access to work with terraform or AWS CLI:

Make sure to unset the AWS variables:
```
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
```

The following set-up is based on the README of assume-role [tool](https://github.com/remind101/assume-role)

Setup a profile for each role you would like to assume in `~/.aws/config`.

As an example:

```
[profile default]
region = eu-west-2
output = json

[profile admin]
region = eu-west-2
role_arn = <role-arn>
mfa_serial = <mfa-arn>
source_profile = default
```

Your `source_profile` needs to match your profile in `~/.aws/credentials`.
```
[default]
aws_access_key_id = <your-aws-access-key-id>
aws_secret_access_key = <your-aws-secret-access-key>
```

#### Assume role with elevated permissions

##### Install `assume-role` locally
`brew install remind101/formulae/assume-role`

Run the following command with the profile configured in your `~/.aws/config`:
`assume-role admin`

##### Run `assume-role` with dojo
Run the following command with the profile configured in your `~/.aws/config`:
`eval $(dojo "echo <mfa-code> | assume-role admin")`

Run the following command to confirm you assumed the correct role:
`aws sts get-caller-identity`

Work with terraform as per usual.

## AWS SSM Parameters Design Principles

When creating the new ssm keys, please follow the agreed convention as per the design specified below:

* all parts of the keys are lower case
* the words are separated by dashes (`kebab case`)
* `env` is optional

### Design:
Please follow this design to ensure the ssm keys are easy to maintain and navigate through:

| Type               | Design                                  | Example                                               |
| -------------------| ----------------------------------------| ------------------------------------------------------|
| **User-specified** |`/repo/<env>?/user-input/`               | `/repo/${var.environment}/user-input/db-username`     |
| **Auto-generated** |`/repo/<env>?/output/<name-of-git-repo>/`| `/repo/output/prm-deductions-base-infra/root-zone-id` |


# VPN

## Generating VPN client keys

1. [Gain access to AWS as described above](#Access-to-AWS)
1. Generate VPN client configuration for each environment:
```
NHS_ENVIRONMENT=<env-name> ./tasks generate_vpn_client_crt <your-first-name.your-last-name>
```
E.g. to get access to both dev and test environments, you'll need to run:
```
NHS_ENVIRONMENT=dev ./tasks generate_vpn_client_crt <your-first-name.your-last-name>
NHS_ENVIRONMENT=test ./tasks generate_vpn_client_crt <your-first-name.your-last-name>
```

## Creating CA

All vpn endpoints use the same CA which needs to be generated only once.

The operation is automated, mostly for reference:
```
./tasks generate_vpn_ca
```

## Creating VPN server certificate

Each VPN endpoint has its own server certificate signed by above CA. The operation is automated in the task:
```
NHS_ENVIRONMENT=dev ./tasks generate_vpn_server_crt
```
It is part of a pipeline that deploys each environment.


# Useful CloudWatch Logs Insights Queries for Repository Codebases
They will be also stored in a Repo folder in CloudWatch Insights. More information here:  https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_Insights-Saving-Queries.html

###Tabular Views - enable to see service in the separate CloudWatch column:

`fields @timestamp, @message, service`<br/>
`| filter @message not like /(H|h)ealth/`<br/>
`| sort @timestamp desc`


###Filter by severity levels - useful if we would like to see all the errors:

`fields @timestamp, @message, service`<br/>
`| filter @message not like /(H|h)ealth/`<br/>
`| filter @message like /(ERROR|error|Error)/`<br/>
`| filter @message like /500/`<br/>
`| sort @timestamp desc`

###Dev - non-compliant messages

`fields @timestamp, @message, @logStream`<br/>
`| filter not ispresent(service) or not ispresent(environment) or not ispresent(level)`<br/>
`| sort @timestamp desc`

###Log streams by non-compliance

`fields @timestamp, @message, @logStream`<br/>
`| filter not ispresent(service) or not ispresent(environment) or not ispresent(level)`<br/>
`| stats count(*) by @logStream`

###Test - All level messages above DEBUG

`fields @timestamp, level, service, @message`<br/>
`| filter level != 'DEBUG'`<br/>
`| filter @message not like /(H|h)ealth/`<br/>
`| sort @timestamp desc`

###Test - Interactions with queue raw-inbound

`fields @timestamp, @message, service, correlationId`<br/>
`| filter queue = 'raw-inbound'`<br/>
`| sort @timestamp desc`
 