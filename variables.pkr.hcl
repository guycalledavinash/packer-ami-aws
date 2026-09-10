variable "region" {
  type        = string
  description = "AWS region where Packer builds the AMI. Defaults to AWS_DEFAULT_REGION when set."
  default     = env("AWS_DEFAULT_REGION")
}

variable "ubuntu_release" {
  type        = string
  description = "Ubuntu release identifier used in Canonical AMI names."
  default     = "jammy-22.04"

  validation {
    condition     = can(regex("^[a-z]+-[0-9]+\\.[0-9]+$", var.ubuntu_release))
    error_message = "ubuntu_release must use Canonical's release format, for example jammy-22.04."
  }
}

variable "ubuntu_architecture" {
  type        = string
  description = "Ubuntu AMI architecture identifier used in Canonical AMI names."
  default     = "amd64"

  validation {
    condition     = contains(["amd64", "arm64"], var.ubuntu_architecture)
    error_message = "ubuntu_architecture must be either amd64 or arm64."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID that contains the build subnet."
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the temporary Packer build instance."
}

variable "security_group_id" {
  type        = string
  description = "Security group ID that permits SSH from the machine running Packer."
}

variable "instance_type" {
  type        = string
  description = "Temporary EC2 instance type used during the build."
  default     = "t3.micro"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for the source AMI."
  default     = "ubuntu"
}

variable "ami_name_prefix" {
  type        = string
  description = "Prefix for the generated AMI name and Name tag."
  default     = "packer-nginx-docker"
}

variable "web_content_repo" {
  type        = string
  description = "Git repository containing index.html, style.css, and scorekeeper.js."
  default     = "https://github.com/guycalledavinash/webhook-testing.git"
}

variable "web_root" {
  type        = string
  description = "Destination directory served by nginx."
  default     = "/var/www/html"
}
