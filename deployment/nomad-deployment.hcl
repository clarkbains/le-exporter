job "le-exporter" {
  region      = "global"
  datacenters = ["cwdc"]

  group "le-exporter" {
    count = 1

    network {
      port "http" {
        to = 5566
      }
    }

    service {
      name = "le-challenge-server"
      port = "http"
      check {
        path     = "/health"
        type     = "http"
        interval = "2s"
        timeout  = "1s"
      }

      #Have traefik send all the acme challenges to us
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.acme-challenge-server.rule=PathPrefix(`/.well-known/acme-challenge/`)",
        "traefik.http.routers.acme-challenge-server.entrypoints=http",
      ]
    }

    task "le-exporter" {
      driver = "docker"
      config {
        image = "ghcr.io/clarkbains/le-exporter:latest"
        ports = ["http"]
      }

      vault {
        policies    = ["le-exporter"]
        change_mode = "restart"
      }

#Once DNS is working inside the containers, these should be changed to use the dns names
# consul.service.consul
# https://active.vault.service.consul:8200
      template {
        data        = <<EOF
ACME_PEM_PATH=/local/privkey
CONSUL_HTTP_TOKEN={{ with secret "consul/creds/le-exporter" }}{{.Data.token}}{{ end }}
CONSUL_HTTP_HOST=192.168.25.32
VAULT_HTTP_ADDR=https://192.168.25.137:8200
EOF
        env         = true
        destination = "local/config.env"
        change_mode = "restart"
      }

      template {
        data        = <<EOF
{{ with secret "kv/data/projects/system/le-exporter" }}{{ .Data.data.ACCOUNT_KEY }}{{ end }}
EOF
        destination = "/local/privkey"
        change_mode = "restart"
      }

      resources {
        cpu    = 80  # MHz
        memory = 100 # MB      
      }
    }
  }
}
