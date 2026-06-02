log_level = "DEBUG"

data_dir = "/tmp/nomad-srv"

server {
  enabled = true
  bootstrap_expect = 1
}

client {
  enabled = true

  options {
    "docker.privileged.enabled" = "true"
  }

  host_volume "mysql" {
    path      = "/data/projects/brxm_nomad/mysql"
    read_only = false
  }

  host_volume "artifacts" {
    path      = "/data/projects/brxm_nomad/artifacts"
    read_only = true
  }

  host_volume "docker-sock" {
    path      = "/var/run/docker.sock"
    read_only = true
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}


plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled      = true
      # selinuxlabel = "z"
    }
    extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
  }
}







