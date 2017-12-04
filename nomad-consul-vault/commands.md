## Set the AWS environment variables

```bash
$ export AWS_ACCESS_KEY_ID=[AWS_ACCESS_KEY_ID]
$ export AWS_SECRET_ACCESS_KEY=[AWS_SECRET_ACCESS_KEY]
```

## Build an AWS machine image with Packer

[Packer](https://www.packer.io/intro/index.html) is HashiCorp's open source tool 
for creating identical machine images for multiple platforms from a single 
source configuration. The Terraform templates included in this repo reference a 
publicly avaialble Amazon machine image (AMI) by default. The AMI can be customized 
through modifications to the [build configuration script](../shared/scripts/setup.sh) 
and [packer.json](packer.json).

Use the following command to build the AMI:

```bash
$ cd packer
$ packer build packer.json
```

## Provision a cluster with Terraform

`cd` to an environment subdirectory:

```bash
$ cd eu-west-1
```

Update `terraform.tfvars` with your SSH key name and your AMI ID if you created 
a custom AMI:

```bash
region                  = "eu-west-1"
ami                     = "ami-6ce26316"
instance_type           = "t2.medium"
key_name                = "KEY_NAME"
server_count            = "3"
client_count            = "4"
```

You can also modify the `region`, `instance_type`, `server_count`, and `client_count`. 
At least one client and one server are required.

Provision the cluster:

```bash
$ terraform init
$ terraform get
$ terraform plan
$ terraform apply
```

## Access the cluster

SSH to one of the servers using its public IP:

```bash
$ ssh -i /path/to/private/key ubuntu@PUBLIC_IP
```

The infrastructure that is provisioned for this test environment is configured to 
allow all traffic over port 22. This is obviously not recommended for production 
deployments.

## Test

Run a few basic status commands to verify that Consul and Nomad are up and running 
properly:

```bash
$ consul members
$ nomad server-members
$ nomad node-status
```

## Unseal the Vault cluster (optional)

To initialize and unseal Vault, run:

```bash
$ vault init -key-shares=1 -key-threshold=1
$ vault unseal
$ export VAULT_TOKEN=[INITIAL_ROOT_TOKEN]
```

The `vault init` command above creates a single 
[Vault unseal key](https://www.vaultproject.io/docs/concepts/seal.html) for 
convenience. For a production environment, it is recommended that you create at 
least five unseal key shares and securely distribute them to independent 
operators. The `vault init` command defaults to five key shares and a key 
threshold of three. If you provisioned more than one server, the others will 
become standby nodes but should still be unsealed. You can query the active 
and standby nodes independently:

```bash
$ dig active.vault.service.consul
$ dig active.vault.service.consul SRV
$ dig standby.vault.service.consul
```

See the [Getting Started guide](https://www.vaultproject.io/intro/getting-started/first-secret.html) 
for an introduction to Vault.

## Getting started with Nomad & the HashiCorp stack

Use the following links to get started with Nomad and its HashiCorp integrations:

* [Getting Started with Nomad](https://www.nomadproject.io/intro/getting-started/jobs.html)
* [Consul integration](https://www.nomadproject.io/docs/service-discovery/index.html)
* [Vault integration](https://www.nomadproject.io/docs/vault-integration/index.html)
* [consul-template integration](https://www.nomadproject.io/docs/job-specification/template.html)
