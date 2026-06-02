#!/bin/bash


sudo nomad agent -config config-nomad.hcl & disown
#nomad  agent -dev -bind 0.0.0.0 -network-interface='{{ GetDefaultInterfaces | attr "name" }}' &
export NOMAD_ADDR=http://localhost:4646
echo "NOMAD STARTED"
