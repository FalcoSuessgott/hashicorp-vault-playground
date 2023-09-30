output "root_token" {
  value = jsondecode(terracurl_request.init.response).root_token
}

output "unseal_keys" {
  value = jsondecode(terracurl_request.init.response).keys_base64
}
