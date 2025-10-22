package: crab-prod
version: vCMS_prod
variables:
  version_suffix:     "00"
  crabclient_version: "v3.250820"
  crabserver_version: "v3.250818"
  crabserver_packages: ""
sources:
  - git://github.com/dmwm/CRABClient.git?obj=master/%(crabclient_version)s&export=CRABClient&output=/CRABClient-%(crabclient_version)s.tar.gz
  - git://github.com/dmwm/CRABServer.git?obj=master/%(crabserver_version)s&export=CRABServer&output=/CRABServer-%(crabserver_version)s.tar.gz
---
if [ -n "%(crabserver_packages)s" ]; then
  export crabserver_packages=%(crabserver_packages)s
else
  export crabserver_packages="ServerUtilities.py"
fi
INCLUDE crab-build.sh
