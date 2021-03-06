resource "azurerm_api_management_user" "pip_apim_user" {
  api_management_name = azurerm_api_management.pip_apim.name
  resource_group_name = azurerm_api_management.pip_apim.resource_group_name
  user_id             = "5931a75ae4bbd512288c680b"
  first_name          = "Test"
  last_name           = "User"
  email               = "test@hmcts.dev.null"
  state               = "active"
}

resource "azurerm_api_management_subscription" "pip_apim_subscription" {
  api_management_name = azurerm_api_management.pip_apim.name
  resource_group_name = azurerm_api_management.pip_apim.resource_group_name
  user_id             = azurerm_api_management_user.pip_apim_user.id
  product_id          = azurerm_api_management_product.pip_apim_product.id
  display_name        = "Test Subscription"
  state               = "active"
  allow_tracing       = var.environment == "sbox" || var.environment == "dev" || var.environment == "test" ? true : false
}

resource "azurerm_key_vault_access_policy" "shared_kv_premissions" {
  key_vault_id       = data.azurerm_key_vault.infra_key_vault.id
  tenant_id          = data.azurerm_key_vault.infra_key_vault.tenant_id
  object_id          = azurerm_api_management.pip_apim.identity[0].principal_id
  secret_permissions = var.secret_permissions
}

resource "azurerm_key_vault_secret" "subscription_key" {
  name         = "${var.prefix}-${var.product}-sub-key"
  value        = azurerm_api_management_subscription.pip_apim_subscription.primary_key
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  tags         = local.common_tags
}
