#  a simple vault login test
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# encrypt
path "transit/encrypt/kms" {
   capabilities = [ "update" ]
}

# decrypt
path "transit/decrypt/kms" {
   capabilities = [ "update" ]
}

# get key version
path "transit/keys/kms" {
   capabilities = [ "read" ]
}
