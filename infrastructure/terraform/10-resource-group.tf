resource "azurerm_resource_group" "pih_apim_rg" {
  name     = "${var.prefix}-${var.product}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}
