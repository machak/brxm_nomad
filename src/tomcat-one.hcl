job "tomcat-one" {
  datacenters = ["dc1"]
  type = "service"

  group "web-servers" {
    count = 1

    update {
      # canary  = 1
      max_parallel      = 1
      min_healthy_time  = "5s"
      healthy_deadline  = "5m"
      health_check = "task_states"
      # auto_revert = true
      # auto_promote = true
    }

    network {
      port "http" {
        to = 9090
      }
      port "debug-port" {
        to = 8090
      }
    }

    task "tomcat-one" {

      driver = "raw_exec"

      service {
        provider = "nomad"
        name     = "tomcat-one"
        port     = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "5s"
          timeout  = "3s"

        }

      }

      artifact {
        source      = "https://dlcdn.apache.org/tomcat/tomcat-11/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz"
        destination = "local"
        options {
          archive_mode = "tar"
        }
      }

      /*
        NOTE: exec driver is only supported on Linux and raw_exec driver
        doesn't support artifact downloads via file (volumes) so we need to run
        local repository and access file via url e.g.: http://localhost:8888/cms.war,
        see nginx-artifacts.hcl
      */
      artifact {
        source      = "http://localhost:8888/distribution.tar.gz"
        destination = "${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}"
        options {
          archive_mode = "tar"
        }
      }
      template {
        data = file(abspath("./conf/log4j2.xml"))
        destination = "${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}/conf/log4j2.xml"
      }
      template {
        data = file(abspath("./conf/catalina.properties"))
        destination = "${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}/conf/catalina.properties"
      }
      template {
        data = file(abspath("./conf/repository.xml"))
        destination = "${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}/conf/repository.xml"
      }
      template {
        data = file(abspath("./conf/server.xml"))
        destination = "${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}/conf/server.xml"
      }
      template {
        data = file(abspath("./conf/context.xml"))
        destination = "${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}/conf/context.xml"
      }

      config {
        # Always use "run" instead of "start" to keep Tomcat in the foreground.
        # If Tomcat forks to the background, Nomad will think the task crashed.
        command = "local/apache-tomcat-${TOMCAT_VER}/bin/catalina.sh"
        args = ["run"]
      }

      env {
        CLUSTER_ID     = "tomcat-one"
        PROJECT_DATA     = "/data/projects/brxm_nomad/repositories"
        LOG_DIR     = "${PROJECT_DATA}/logs/${CLUSTER_ID}"
        TOMCAT_VER     = "11.0.22"
        # CLUSTER_ID     = "node${uuidv4()}"
        JRC_OPTS       = "-Dorg.apache.jackrabbit.core.cluster.node_id=${CLUSTER_ID}"
        JAVA_OPTS      = "-agentlib:jdwp=transport=dt_socket,address=*:${NOMAD_PORT_debug-port},server=y,suspend=n"
        CATALINA_HOME  = "${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}"
        CATALINA_PID   = "${NOMAD_ALLOC_DIR}/tomcat.pid"
        CATALINA_OUT   = "${NOMAD_ALLOC_DIR}/logs/catalina.out"
        REP_OPTS       = "-Drepo.path=${PROJECT_DATA}/${CLUSTER_ID} -Drepo.bootstrap=false -Drepo.config=file:${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}/conf/repository.xml"
        ADD_OPENS_OPTS = "--add-opens java.xml/com.sun.org.apache.xml.internal.utils=ALL-UNNAMED"
        CATALINA_OPTS  = "${REP_OPTS} ${JRC_OPTS} ${ADD_OPENS_OPTS} -Xmx1024m -Dlog4j.configurationFile=file:${NOMAD_TASK_DIR}/apache-tomcat-${TOMCAT_VER}/conf/log4j2.xml"

      }

      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}