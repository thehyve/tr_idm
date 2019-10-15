# main.tf

# Define terraform backend
terraform {
  required_version = "~> 0.12.0"
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "TheHyve"
    workspaces {
      name = "ipacont8"
    }
  }
}

# Definition of variables
variable "hcloud_token" {
  type = string
  description = "Use -var='hcloud_token=...' CLI option"
}
variable "server" {
  description = "The mapping of servername to server Data Center"
  type = "map"
  default = {
    "etc00" = "nbg1"
    "etc01" = "fsn1"
    "etc10" = "hel1"
  }
}
variable "server_type" {
  type = string
  description = "defines resources for provisioned server"
  default = "cx31-ceph"
}
variable "ssh_key_private" {
  type = string
  description = "Ssh private key to use for connection to a server. Export TF_VAR_ssh_key_private environment variable to define a value."
}
variable "ssh_key" {
  type = string
  description = "An id of public key of ssh key-pairs that will be used for connection to a server. Export TF_VAR_ssh_key environment variable to define a value."
}
variable "remote_user" {
  type = string
  description = "A user being used for a connection to a server. By default is root, unless redefined with user-data (cloud-init)."
  default = "root"
}
variable "server_image" {
  type = string
  description = "An image being used for a server provisioning."
  default = "centos-8"
}

# User Hetzner cloud
provider "hcloud" {
  token = "${var.hcloud_token}"
}

# Create resources
resource "hcloud_server" "host" {
  for_each = var.server
  name = each.key
  location = each.value
  server_type = "${var.server_type}"
  keep_disk = true
  backups = true
  image = "${var.server_image}"
  ssh_keys = [
    "${var.ssh_key}",
  ]
}