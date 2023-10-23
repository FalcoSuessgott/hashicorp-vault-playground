// variables {
//   # GH Action does not allow well-known ports
//   haproxy = {
//     port = 10200
//   }
// }

# 1. only crete vault and tls resources
run "setup_vault" {
  plan_options {
    target = [
      module.tls,
      module.vault
    ]
  }
}

# 2. execute helper module to check http code of Vault URL
run "vault_is_initialized" {
  command = plan

  module {
    source = "./tests/test_utils"
  }

  variables {
    url = "https://127.0.0.1/v1/sys/seal-status"
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
    source = "./tests/test_utils"
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
# waiting for: https://github.com/hashicorp/terraform/pull/34118
// run "esm" {
//   plan_options {
//     target = [
//       module.esm
//     ]
//   }
// }
