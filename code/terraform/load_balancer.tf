resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-webapp-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard" # Required for VMSS and zone-redundancy
}

resource "azurerm_lb" "main" {
  name                = "lb-webapp-prod"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

# Health Probe to ensure traffic is only routed to healthy instances
resource "azurerm_lb_probe" "hp" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "http-running-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

resource "azurerm_lb_rule" "lbr" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule-HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.hp.id
}