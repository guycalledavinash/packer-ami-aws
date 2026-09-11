packer {
  required_version = ">= 1.8.0"

  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name  = "${var.ami_name_prefix}-${local.timestamp}"
}

source "amazon-ebs" "ubuntu_web" {
  ami_name                    = local.ami_name
  associate_public_ip_address = true
  instance_type               = var.instance_type
  region                      = var.region
  security_group_id           = var.security_group_id
  ssh_username                = var.ssh_username
  subnet_id                   = var.subnet_id
  vpc_id                      = var.vpc_id

  # Canonical publishes Ubuntu AMIs with this name pattern in every AWS region.
  # Limiting the owner and image characteristics prevents an unrelated AMI from
  # being selected when Packer resolves the most recent matching image.
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*/ubuntu-${var.ubuntu_release}-${var.ubuntu_architecture}-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  tags = {
    Name        = local.ami_name
    ManagedBy   = "packer"
    Application = "nginx-docker-web"
  }
}

build {
  name    = "nginx-docker-ubuntu-ami"
  sources = ["source.amazon-ebs.ubuntu_web"]

  provisioner "shell" {
    environment_vars = [
      "WEB_CONTENT_REPO=${var.web_content_repo}",
      "WEB_ROOT=${var.web_root}",
    ]

    script = "scripts/install-web-stack.sh"
  }
}
