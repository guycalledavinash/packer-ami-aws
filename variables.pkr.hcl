variable "region" {
  type        = string
  description = "AWS region where Packer builds the AMI. Defaults to AWS_DEFAULT_REGION when set."
  default     = env("AWS_DEFAULT_REGION")
}

variable "source_ami" {
  type        = string
  description = "Ubuntu source AMI ID to use as the base image."
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
