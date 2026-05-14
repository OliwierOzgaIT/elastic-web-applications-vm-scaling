# Virtual Machine Scale Set (VMSS)
resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "vmss-webapp-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard_D2s_v3" # Cost-effective burstable instance
  instances           = 2                 # Initial instance count for high availability
  admin_username      = "azureuser"

  # SSH Key for secure access
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  # OS Image configuration (Ubuntu 22.04 LTS)
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  # Network Configuration
  network_interface {
    name    = "nic-webapp"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
    }
  }

  # Automated Nginx installation and startup
  custom_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
  )
}