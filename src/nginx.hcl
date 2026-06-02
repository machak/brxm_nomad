job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        static = 80
      }
    }

    service {
      provider = "nomad"
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:alpine3.23-slim"

        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = file(abspath("./conf/nginx.conf"))
        destination   = "local/nginx.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
     /* template {
        data = file(abspath("./conf/nginx.conf"))
        destination   = "local/snippets/nginx.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }*/
    }
  }
}
/*
data = <<EOF
upstream backend {
{{ range service "tomcat-service" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 80;

   location / {
      proxy_pass http://backend;
   }
}
EOF*/