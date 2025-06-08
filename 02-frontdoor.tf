# resource "azurerm_cdn_frontdoor_profile" "fd-profile" {
#   name                     = "frontdoor-profile-${var.project}"
#   resource_group_name      = azurerm_resource_group.rg.name
#   response_timeout_seconds = 16
#   sku_name                 = "Standard_AzureFrontDoor"
#   tags                     = var.tags
# }

# resource "azurerm_cdn_frontdoor_endpoint" "web" {
#   name                     = "web"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd-profile.id
#   tags                     = var.tags
# }

# resource "azurerm_cdn_frontdoor_rule_set" "cache" {
#   name                     = "caching"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd-profile.id
# }

# resource "azurerm_cdn_frontdoor_origin_group" "web" {
#   name                     = "web"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd-profile.id

#   load_balancing {
#     additional_latency_in_milliseconds = 0
#     sample_size                        = 16
#     successful_samples_required        = 3
#   }
# }

# resource "azurerm_cdn_frontdoor_rule" "cache" {
#   name                      = "static"
#   cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.cache.id
#   order                     = 1
#   behavior_on_match         = "Stop"

#   conditions {
#     url_file_extension_condition {
#       operator     = "Equal"
#       match_values = ["css", "js", "ico", "png", "jpeg", "jpg", ".map"]
#     }
#   }

#   actions {
#     route_configuration_override_action {
#       compression_enabled = true
#       cache_behavior      = "HonorOrigin"
#     }
#   }

#   depends_on = [
#     azurerm_cdn_frontdoor_origin_group.web,
#     azurerm_cdn_frontdoor_origin.web
#   ]
# }


# resource "azurerm_cdn_frontdoor_origin" "web" {
#   depends_on                     = [azurerm_storage_account.web]
#   name                           = "web"
#   cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.web.id
#   enabled                        = true
#   certificate_name_check_enabled = false
#   host_name                      = azurerm_storage_account.web.primary_web_host
#   http_port                      = 80
#   https_port                     = 443
#   origin_host_header             = azurerm_storage_account.web.primary_web_host
#   priority                       = 1
#   weight                         = 1
# }


# resource "azurerm_cdn_frontdoor_route" "default" {
#   name                          = "default"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.web.id
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id
#   cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.web.id]
#   cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.cache.id]
#   enabled                       = true

#   forwarding_protocol    = "MatchRequest"
#   https_redirect_enabled = true
#   patterns_to_match      = ["/*"]
#   supported_protocols    = ["Http", "Https"]
#   link_to_default_domain = true
# }