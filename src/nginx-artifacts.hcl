job "nginx-artifacts" {

  datacenters = ["dc1"]
  type = "service"

  group "web-artifacts" {
    count = 1


    volume "assets" {
      type      = "host"
      read_only = true
      source    = "artifacts"
    }
    
    network {
      mode = "bridge"
      port "http" {
        to = 80
        static = 8888
      }
    }

    service {
      provider = "nomad"
      name     = "web-artifacts"
      port     = "http"
      
    }

    task "web-artifacts" {

      driver = "docker"
      config {
        image = "nginx:alpine3.23-slim"
        ports = ["http"]
      }

      volume_mount {
        volume      = "assets"
        destination = "/usr/share/nginx/html"
        read_only   = true
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}