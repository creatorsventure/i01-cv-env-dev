ui = true
api_addr = "http://local.docker.vault:8200"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

storage "file" {
  path = "/vault/data"
}

default_lease_ttl = "168h"
max_lease_ttl     = "720h"