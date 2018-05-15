###############################################################################
# Developed by Eduardo Ortega @MagenTys
# Free distribution, free usage
# Demo purposee only
###############################################################################

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "demo_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "demo_vnet" {
  name                = "Demo-Terraform-VNet"
  address_space       = ["${var.vnet_cidr}"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.demo_rg.name}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "demo_subnet_1" {
  name                 = "Demo-Subnet-1"
  address_prefix       = "${var.subnet1_cidr}"
  virtual_network_name = "${azurerm_virtual_network.demo_vnet.name}"
  resource_group_name  = "${azurerm_resource_group.demo_rg.name}"
}

resource "azurerm_subnet" "demo_subnet_2" {
  name                 = "Demo-Subnet-2"
  address_prefix       = "${var.subnet2_cidr}"
  virtual_network_name = "${azurerm_virtual_network.demo_vnet.name}"
  resource_group_name  = "${azurerm_resource_group.demo_rg.name}"
}

resource "azurerm_public_ip" "demo_pip" {
  name                         = "Demo-Terraform-PIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.demo_rg.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_network_interface" "public_nic" {
  name                      = "Demo-Terraform-Web"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.demo_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg_web.id}"

  ip_configuration {
    name                          = "Demo-Terraform-WebPrivate"
    subnet_id                     = "${azurerm_subnet.demo_subnet_1.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.demo_pip.id}"
  }

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_network_interface" "private_nic" {
  name                      = "Demo-Terraform-DB"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.demo_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.terraform_nsg_db.id}"

  ip_configuration {
    name                          = "Demo-Terraform-DBPrivate"
    subnet_id                     = "${azurerm_subnet.demo_subnet_2.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.2.5"
  }

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_virtual_machine" "demo_frontend" {
  name                  = "Demo-Terraform-Linux"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.demo_rg.name}"
  network_interface_ids = ["${azurerm_network_interface.public_nic.id}"]
  vm_size               = "Standard_DS1_v2"

  #This will delete the OS disk and data disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${azurerm_resource_group.demo_rg.name}-OSdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ubuntuweb"
    admin_username = "${var.vm_username}"
    admin_password = "${var.vm_password}"

    #admin_password = "${data.external.azure_secrets.result.admin-password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "${var.environment}"
  }

  provisioner "local-exec" {
    command = "./provision/environment/dev/scripts/dynamicinventory.sh"
  }

  provisioner "local-exec" {
    command = "sleep 180;sed -i 's/{host}/${azurerm_public_ip.demo_pip.ip_address}/g' ./provision/environment/dev/inventory/inventory"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ./provision/environment/dev/playbooks/webservers.yml -i ./provision/environment/dev/inventory/inventory"
  }
}
