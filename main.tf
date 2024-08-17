terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = var.location
  resource_group_name = var.resource_gp_nm

  tags = {
    environment = "DevOps"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = var.resource_gp_nm
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_gp_nm

  security_rule {
    name                       = "AllowVMs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_ranges          = ["80", "443"]
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "DevOps"
  }
}

resource "azurerm_subnet_network_security_group_association" "internal" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id
}


resource "azurerm_public_ip" "public_ip" {
  count = var.counter + 1
  name                = "public-ip${count.index + 1}"
  resource_group_name = var.resource_gp_nm
  location            = azurerm_virtual_network.main.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "DevOps"
  }
}

resource "azurerm_network_interface" "main" {
  count = var.counter
  name                = "${var.prefix}-nic${count.index + 1}"
  resource_group_name = var.resource_gp_nm
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip[count.index].id
  }

  tags = {
    environment = "DevOps"
  }
}

resource "azurerm_lb" "loadb" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = var.resource_gp_nm

  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = azurerm_public_ip.public_ip[var.counter].id
  }
}

resource "azurerm_lb_backend_address_pool" "loadb" {
  loadbalancer_id = azurerm_lb.loadb.id
  name            = "${var.prefix}-lbe"
}

resource "azurerm_network_interface_backend_address_pool_association" "loadb" {
  count = var.counter
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.loadb.id
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-aset"
  location            = var.location
  resource_group_name = var.resource_gp_nm

  tags = {
    environment = "DevOps"
  }
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = var.resource_gp_nm
}

resource "azurerm_linux_virtual_machine" "main" {
  count = var.counter
  name                            = "${var.prefix}-vm${count.index + 1}"
  resource_group_name             = var.resource_gp_nm
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  source_image_id = data.azurerm_image.image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  availability_set_id = azurerm_availability_set.main.id
}

resource "azurerm_managed_disk" "disk" {
  count = var.counter
  name                 = "${var.prefix}-disk${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_gp_nm
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "DevOps"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
  count = var.counter
  managed_disk_id    = azurerm_managed_disk.disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}
