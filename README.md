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

### AWS helpers

This repository imports shared AWS helpers from [prm-deductions-support-infra](https://github.com/nhsconnect/prm-deductions-support-infra/).
They can be found `utils` directory after running any task from `tasks` file.

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

## Revoking VPN client keys
1. Open the ovpn file that you want to revoke access for. This can be found in the directory where it was created: prm-deductions-infra → client-config. You may have an ovpn file per environment and will be named something like dev.john.smith.ovpn
2. Copy the certificate from the ovpn - this is everything between the <cert>  </cert> tags. If someone else is revoking your certificates for you, send this certificate to them securely. 
3. Create a new file in the prm-deductions-infra → utils directory, named similarly to your ovpn file but ending with .crt instead - dev.john.smith.crt
4. Paste your copied certificate into this new file
5. [Gain access to AWS as described above](#Access-to-AWS)
6. Revoke VPN client configuration for each environment:
```
NHS_ENVIRONMENT=<env-name> ./tasks revoke_vpn_client_crt <your-first-name.your-last-name>
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

## Replacing VPN server certificate

When VPN CA is changed, the old certificate is still being used by the VPN endpoint. As a result, running the command ```NHS_ENVIRONMENT=dev ./tasks generate_vpn_server_crt``` to generate a developer’s VPN certificate won’t create a successful VPN connection. The VPN endpoint needs to be deleted or modified not to use the old certificate.

If you need to delete the VPN endpoint please use terraform.

Please note that when the VPN endpoint is deleted in the AWS console, it may cause some sync-up issues with the terraform state as terraform is still looking for the previous VPN endpoint ID and its resources.

The newly created certificate should be associated with the VPN endpoint. If you deleted VPN endpoint, the terraform will handle that association. Otherwise you need to modify the VPN endpoint to use new certificate in the AWS console.

After the deletion of the old VPN certificate, each VPN certificate should be recreated locally and the old certificates should be replaced. A developer can run ```NHS_ENVIRONMENT=dev ./tasks generate_vpn_server_crt``` locally to generate the new VPN certificate.

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
