# 1. only create vault and tls resources
run "setup_vault" {
  plan_options {
    target = [
      module.vault
    ]
  }
}

# 2. execute helper module to check http code of Vault URL
run "vault_is_initialized" {
  command = plan

  module {
    source = "./tests/http_get"
  }

  variables {
    ca_cert  = run.setup_vault.ca_cert
    insecure = null
    url      = "https://127.0.0.1/v1/sys/seal-status"
  }

  assert {
    condition     = data.http.request.status_code == 200
    error_message = "Vault API not Available (Want: 200, Got: ${data.http.request.status_code})"
  }

  assert {
    condition     = jsondecode(data.http.request.response_body).initialized
    error_message = "Vault is not initialized (Want: true, Got: ${jsondecode(data.http.request.response_body).initialized})"
  }

  assert {
    condition     = jsondecode(data.http.request.response_body).sealed == false
    error_message = "Vault is not unsealed (Want: false, Got: ${jsondecode(data.http.request.response_body).sealed})"
  }
}

# 3. create only minikube
run "setup_minikube" {
  plan_options {
    target = [
      module.minikube
    ]
  }
}

# 4. check if KubeAPI URL is available
run "kubeapi_is_available" {
  command = plan

  module {
    source = "./tests/http_get"
  }

  variables {
    url = "https://127.0.0.1:8443"
  }

  assert {
    condition     = data.http.request.status_code == 403
    error_message = "Kubernetes API not Available (Want: 403, Got: ${data.http.request.status_code})"
  }
}

# 5. run esm
run "setup_esm" {
  plan_options {
    target = [
      module.esm
    ]
  }
}

# 6. check if ESM Secret has been created
run "esm_secret_is_created" {
  command = plan

  module {
    source = "./tests/external_cmd"
  }

  variables {
    command = "kubectl get secret -n esm esm-secret -o json | jq '.data | map_values(@base64d)'"
  }

  assert {
    condition     = length(data.shell_script.command.output) == 2
    error_message = "ESM Secret has not been created."
  }
}

# 7. run vso
run "setup_vso" {
  plan_options {
    target = [
      module.vso
    ]
  }
}

# 8. check if VSO Secret has been created
run "vso_secret_is_created" {
  command = plan

  module {
    source = "./tests/external_cmd"
  }

  variables {
    command = "kubectl get secret -n vso vso-secret -o json | jq '.data | map_values(@base64d)'"
  }

  assert {
    condition     = length(data.shell_script.command.output) == 3 # vso always adds a _raw field to the secret
    error_message = "VSO Secret has not been created."
  }
}

# 9. run cm
run "setup_cm" {
  plan_options {
    target = [
      module.vault_pki,
      module.cm
    ]
  }
}

# 10. check kuard demo app is tls secured
run "kuard_verifies_using_ca_cert" {
  command = plan

  module {
    source = "./tests/http_get"
  }

  variables {
    ca_cert  = run.setup_vault.ca_cert
    url      = "https://${run.setup_minikube.minikube_ip}.nip.io"
    insecure = null
  }

  assert {
    condition     = data.http.request.status_code == 200
    error_message = "Kuard Demo App is cannot be verified using the CA Cert (Want: 200, Got:${data.http.request.status_code})."
  }
}
