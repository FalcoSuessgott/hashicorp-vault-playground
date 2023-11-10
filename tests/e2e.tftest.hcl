# only create vault and tls resources
run "setup_vault" {
  plan_options {
    target = [
      module.vault
    ]
  }
}

# execute helper module to check http code of Vault URL
run "vault_is_initialized" {
  command = plan

  module {
    source = "./tests/http"
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

# create database
run "setup_database" {
  plan_options {
    target = [
      module.database
    ]
  }
}

# check kuard demo app is tls secured
run "mysql_user_is_created" {
  command = plan

  module {
    source = "./tests/http"
  }

  variables {
    ca_cert  = run.setup_vault.ca_cert
    insecure = null
    header = {
      "X-Vault-Token" = run.setup_vault.root_token
    }
    url = "https://127.0.0.1/v1/databases/creds/mysql"
  }

  assert {
    condition     = data.http.request.status_code == 200
    error_message = "Error while generating MySQL Credentials (Want: 200, Got:${data.http.request.status_code})."
  }
}

# create only minikube
run "setup_minikube" {
  plan_options {
    target = [
      module.minikube
    ]
  }
}

# check if KubeAPI URL is available
run "kubeapi_is_available" {
  command = plan

  module {
    source = "./tests/http"
  }

  variables {
    url = "https://127.0.0.1:8443"
  }

  assert {
    condition     = data.http.request.status_code == 403
    error_message = "Kubernetes API not Available (Want: 403, Got: ${data.http.request.status_code})"
  }
}

# run esm
run "setup_esm" {
  plan_options {
    target = [
      module.esm
    ]
  }
}

# check if ESM Secret has been created
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

# run vso
run "setup_vso" {
  plan_options {
    target = [
      module.vso
    ]
  }
}

# check if VSO Secret has been created
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

# check kuard demo app is tls secured
run "kuard_verifies_using_ca_cert" {
  command = plan

  module {
    source = "./tests/http"
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

# setup vault agent injector
run "setup_vai" {
  plan_options {
    target = [
      module.vai
    ]
  }
}

# check if vai injected secrets into pod
run "vai_secret_is_injected" {
  command = plan

  module {
    source = "./tests/external_cmd"
  }

  variables {
    command = "kubectl exec -n vai -it $(kubectl get pods -l=app=kuard -n vai --no-headers -o custom-columns=\":metadata.name\") -- cat /vault/secrets/secrets.txt"
  }

  assert {
    condition     = length(data.shell_script.command.output) == 2
    error_message = "VAI Secret is not injected into Pod"
  }
}
