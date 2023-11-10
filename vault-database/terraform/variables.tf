variable "database" {
  type = object({
    name     = string
    username = string
    password = string
  })
  default = {
    name     = "vault-playgound"
    username = "root"
    password = "root"
  }
}
