
# Add outputs for auto-testing script
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "public_ip_name" {
  value = azurerm_public_ip.lb_pip.name
}