resource "azurerm_virtual_machine" "demo_vm" {
  name                = "${var.demo_vm_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.azurerg.name}"

  #    network_interface_ids = ["${azurerm_network_interface.azurenic.id}"]
  network_interface_ids = ["${element(azurerm_network_interface.azurenic_sec.*.id, count.index)}"]
  vm_size               = "${var.demo_vm_size}"

  storage_image_reference {
    publisher = "${var.demo_publish}"
    offer     = "${var.demo_offer}"
    sku       = "${var.demo_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.demo_srvr_vm_name}-OSdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "${var.demo_vm_name}"
    admin_username = "${var.demo_admin_username}"
    admin_password = "${var.demo_adminpassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}