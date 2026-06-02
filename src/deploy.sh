#!/bin/bash
## purge all:
nomad job stop -purge web-artifacts
nomad job stop -purge nginx
nomad job stop -purge mysql-server
nomad job stop -purge tomcat-one
nomad job stop -purge tomcat-two

nomad job plan nginx-artifacts.hcl
nomad job run -check-index 0 nginx-artifacts.hcl

nomad job plan mysql.hcl
nomad job run -check-index 0 mysql.hcl

nomad job plan tomcat-one.hcl
nomad job run -check-index 0 tomcat-one.hcl

nomad job plan tomcat-two.hcl
nomad job run -check-index 0 tomcat-two.hcl

nomad job plan nginx.hcl
nomad job run -check-index 0 nginx.hcl
