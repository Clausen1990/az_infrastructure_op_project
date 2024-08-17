variable "prefix" {
  description = "The prefix which should be used for all resources."
  default = "udacity"
}

variable "resource_gp_nm" {
  description = "The name of the resource group."
  default = "Azuredevops"
}

variable "location" {
  description = "The Azure Region in which all resources will be created."
  default = "East US"
}

variable "admin_username" {
  description = "The admin username for the VM being created."
  default = "adminuser"
}

variable "admin_password" {
  description = "The password for the VM being created."
  default = "Ud4c1ty1"
}

variable "packer_image_name" {
  description = "The name of the Packer image"
  default     = "PackerImage"
}

variable "counter" {
  description = "the number of VMs required"
  default = 2
}
