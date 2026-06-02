
# Prerequisites

### Nomad
https://developer.hashicorp.com/nomad/install

### Docker
https://docs.docker.com/engine/install/


# Clone project:
```shell
git clone https://github.com/machak/brxm_nomad.git
cd tomcat_nomad
```
# Adjust directories in "config-nomad.hcl" file for volumes:

```shell
  host_volume "mysql" {
    path      = "/data/projects/brxm_nomad/mysql"
    read_only = false
  }

  host_volume "artifacts" {
    path      = "/data/projects/brxm_nomad/artifacts"
    read_only = true
  }
```


# Adjust directories in tomcat-one.hcl and tomcat-two.hcl for repository location:
```shell
PROJECT_DATA   = "/data/projects/brxm_nomad/repositories"
```
In above example, final repository locations will be
```shell
"/data/projects/brxm_nomad/repositories/tomcat-one"
"/data/projects/brxm_nomad/repositories/tomcat-two"
```

# Start Nomad agent:

```shell
chmod +x run.sh
sudo ./run.sh
# open nomad ui in browser *http://localhost:4646*
nomad ui
```

# Build BRXM project dist and copy it to the "artifacts" directory:
```shell
mvn package && mvn -P dist 
cp target/myproject-0.1.0-SNAPSHOT-distribution.tar.gz /data/projects/brxm_nomad/artifacts/distribution.tar.gz    
  
# Deploy all artifacts
```shell
chmod +x deploy.sh
./deploy.sh
```

Tomcats should be running on ports 9090 and 9091, with JVM debug ports on 8090 and 8091 respectively.
Nginx should be running on port 80.
Mysql should be running on port 3306 (user:hippo, password:hippo).
Artifacts server (nginx) should be running on port 8888 (http://localhost:8888).
NOTE: Artifacts server is only needed to download artifacts from the repository (it is not possible to use "file:" references).

# Deployment of individual jobs:
## Plan:
```shell
nomad job plan nginx.hcl    
```
## Run:
In case there are no errors, submit job which is printed in the console, e.g:
```shell
nomad job run -check-index 6766 nginx.hcl
```
```

           
### Optional to access sites via nginx proxy http://www.example.com/ and http://cms.example.com/cms/

```shell
# add to /etc/hosts

127.0.0.1 cms.example.com
127.0.0.1 www.example.com

```

### Change tomcat versions in tomcat-one.hcl and tomcat-two.hcl
                              

 


## Troubleshooting
#### If nomad is not running and no errors are printed, run:
```shell
sudo nomad agent -config config-nomad.hcl
```

