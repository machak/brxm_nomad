job "mysql-server" {
  datacenters = ["dc1"]
  type = "service"

  group "mysql-server" {
    count = 1

    volume "mysql" {
      type      = "host"
      read_only = false
      source    = "mysql"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mysql-server" {
      driver = "docker"

      volume_mount {
        volume      = "mysql"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      env = {
        MYSQL_ROOT_PASSWORD = "password"
        MYSQL_USER          = "hippo"
        MYSQL_PASSWORD      = "hippo"
        MYSQL_DATABASE      = "hippo"
      }

      config {
        image = "mysql:9.7.0"

        ports = ["db"]
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        provider = "nomad"
        name     = "mysql-server"
        port     = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    network {
      mode = "bridge"
      port "db" {
        static = 3306
      }
    }
  }
}
