# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
This repo deploys a customizable, scalable web server in Azure using a Packer template and a Terraform template t.

### Getting Started
1. Clone this repository

2. Install dependencies

### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Update the var.tf file with the variable aplicable to you:

* prefix: The prefix which should be used for all resources
* resource_gp_nm: The name of the resource group. All resources will be under the same resource group
* location: The Azure Region in which all resources will be created
* admin_username: The admin username for the VM being created
* admin_password: The password for the VM being created
* packer_image_name: The name of the Packer image
* counter: the number of VMs required
<br />

2. Run Packer template by:

    First exporting:

* ARM_SUBSCRIPTION_ID= "<your_value>"  <br />
* ARM_CLIENT_ID= "<your_value>" <br />
* ARM_CLIENT_SECRET= "<your_value>"

    Then run <code> packer build </code>

3. Run <code> terraform plan</code>
if sucessful run <code> terraform apply</code>
<br />
* If desired, you can put a <code>-out</code> flag and a file name ".plan" to save the terraform plan in a file

### Output
If terraform runs successfully you should receive a message:

<code>Apply complete! Resources: 20 added, 0 changed, 0 destroyed.</code>

You will be able to see all the resources in the Azure portal.
