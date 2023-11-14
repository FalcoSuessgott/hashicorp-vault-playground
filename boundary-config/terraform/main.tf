# The global scope is the outermost scope. There is always a single global scope and it cannot be deleted. The global scope can directly contain: users, groups, auth methods, and organizations.
resource "boundary_scope" "org" {
  scope_id    = "global"
  name        = "playground"
  description = "Vault Playground"

  auto_create_admin_role   = false
  auto_create_default_role = false
}

# A project is a type of scope used to organize resources such as targets and host catalogs.
resource "boundary_scope" "project" {
  name                     = "minikube"
  description              = "Local Minikube Cluster"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = false
  auto_create_default_role = false
}

# Auth methods allow users to authenticate within a scope.
resource "boundary_auth_method" "password" {
  name        = "basic"
  description = "Password auth method"
  type        = "password"
  scope_id    = boundary_scope.org.id
}

resource "boundary_account_password" "admin" {
  name           = "admin"
  description    = "Local Admininistrator Account"
  login_name     = "admin"
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

# Users are entities authorized to access Boundary. Users may be assigned to roles as principals, thus receiving role grants.
resource "boundary_user" "admin" {
  name        = boundary_account_password.admin.name
  account_ids = [boundary_account_password.admin.id]
  scope_id    = boundary_scope.org.id
}

#  Roles are collections of capability grants and the principals (users and groups) assigned to them.
resource "boundary_role" "global_anon_listing" {
  name     = "Global Anon Listing"
  scope_id = boundary_scope.org.id
  grant_strings = [
    "ids=*;type=auth-method;actions=list,authenticate",
    "ids=*;type=scope;actions=list,no-op",
    "ids={{.Account.Id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

#  Roles are collections of capability grants and the principals (users and groups) assigned to them.
resource "boundary_role" "org_anon_listing" {
  name     = "Org Anon Listing"
  scope_id = boundary_scope.org.id
  grant_strings = [
    "ids=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "ids={{.Account.Id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

#  Roles are collections of capability grants and the principals (users and groups) assigned to them.
resource "boundary_role" "org_admin" {
  name           = "Org Admin"
  scope_id       = "global"
  grant_scope_id = boundary_scope.org.id
  grant_strings = [
    "ids=*;type=*;actions=*"
  ]
  principal_ids = [boundary_user.admin.id]
}

#  Roles are collections of capability grants and the principals (users and groups) assigned to them.
resource "boundary_role" "project_admin" {
  name           = "Project Admin"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  grant_strings = [
    "ids=*;type=*;actions=*"
  ]
  principal_ids = [boundary_user.admin.id]
}

resource "vault_policy" "boundary" {
  name = "boundary-minikube"

  policy = file("${path.module}/../files/vault-boundary-k8s.hcl")
}

resource "vault_token" "boundary" {
  policies = [vault_policy.boundary.name]

  renewable = true
  no_parent = true
  period    = "24h"
}

# A credential store is a collection of credentials and credential libraries.
resource "boundary_credential_store_vault" "this" {
  name        = "Vault"
  description = "Local HashiCorp Vault Cluster"
  address     = "https://host.docker.internal:443"
  token       = vault_token.boundary.client_token
  scope_id    = boundary_scope.project.id

  ca_cert = try(file("${path.root}/vault-tls/output/ca.crt"), null)
}

# A credential library is a resource that provides credentials.
resource "boundary_credential_library_vault" "this" {
  name                = "minikube"
  description         = "Credentials for Minikube Cluster"
  credential_store_id = boundary_credential_store_vault.this.id
  path                = "minikube/creds/minikube"

  http_method = "POST"
  http_request_body = jsonencode({
    kubernetes_namespace = "default"
  })
}

#  A host catalog is a collection of hosts and host sets.
resource "boundary_host_catalog_static" "this" {
  name        = "Minikube"
  description = "Minikube Cluster Controlplane"
  scope_id    = boundary_scope.project.id
}

#  A host is a resource that may be accessed by a Boundary target.
resource "boundary_host_static" "minikube" {
  name        = "minikube"
  description = "Minikube API"
  address     = var.minikube_ip

  host_catalog_id = boundary_host_catalog_static.this.id
}

#  A host set is a collection of hosts within a host catalog.
resource "boundary_host_set_static" "this" {
  host_catalog_id = boundary_host_catalog_static.this.id
  host_ids        = [boundary_host_static.minikube.id]

}
#  A target is a logical collection of host sets which may be used to initiate sessions.
resource "boundary_target" "this" {
  name         = "minikube"
  description  = "Minikube Target"
  type         = "tcp"
  default_port = "443"

  scope_id = boundary_scope.project.id

  host_source_ids                = [boundary_host_set_static.this.id]
  brokered_credential_source_ids = [boundary_credential_library_vault.this.id]
}

resource "boundary_role" "minikube" {
  name        = "minikube"
  description = "Minikube Role"
  scope_id    = boundary_scope.org.id

  grant_scope_id = boundary_scope.project.id
  grant_strings = [
    "ids=*;type=target;actions=list,no-op",
    "ids=${boundary_target.this.id};actions=authorize-session"
  ]

  principal_ids = [boundary_user.admin.id]
}
