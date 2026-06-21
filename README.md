# packer-ami-aws

Build an Ubuntu Amazon Machine Image (AMI) with:

- nginx enabled at boot
- static web content copied from a configurable Git repository
- Docker Engine installed from Docker's official Ubuntu apt repository

The template is written in Packer HCL2 (`packer.hcl`) and uses separate variable definitions plus a reusable provisioning script for maintainability.

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer) 1.8 or newer
- AWS credentials available to Packer, for example through `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_DEFAULT_REGION`, or through your standard AWS profile/role configuration
- A VPC, public subnet, and security group for the temporary build instance

Ensure the build subnet and security group allow Packer to connect over SSH:

- the subnet auto-assigns or allows an associated public IPv4 address
- the route table has a route to an internet gateway
- the security group allows inbound SSH from the machine running Packer
- outbound internet access is available for apt, GitHub, and Docker package downloads

## Configure variables

Create a local variable file from the example and fill in your AWS resource IDs:

```bash
cp packer-vars.example.hcl packer-vars.pkrvars.hcl
```

```hcl
region            = "us-east-1"
source_ami        = "ami-0123456789abcdef0"
vpc_id            = "vpc-0123456789abcdef0"
subnet_id         = "subnet-0123456789abcdef0"
security_group_id = "sg-0123456789abcdef0"
```

`packer-vars.pkrvars.hcl` is ignored by Git so local infrastructure values are not committed accidentally.

## Build the AMI

Initialize plugins:

```bash
packer init .
```

Format and validate the template:

```bash
packer fmt .
packer validate -var-file=packer-vars.pkrvars.hcl .
```

Build the AMI:

```bash
packer build -var-file=packer-vars.pkrvars.hcl .
```

## Customizing the web content

By default, the AMI copies `index.html`, `style.css`, and `scorekeeper.js` from `https://github.com/guycalledavinash/webhook-testing.git` into `/var/www/html`.

Override the content repository at build time:

```bash
packer build \
  -var-file=packer-vars.pkrvars.hcl \
  -var='web_content_repo=https://github.com/example/my-static-site.git' \
  .
```

The repository must contain `index.html`, `style.css`, and `scorekeeper.js` at its root.

## Security notes

This project no longer replaces Docker's systemd unit or exposes the unauthenticated Docker TCP socket on `0.0.0.0:2375`. Exposing that socket allows remote root-equivalent access to the instance. Use SSH, TLS-protected Docker contexts, or a private remote-management approach instead.
