#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 jq python python-dev python-pip jq

sudo pip install yq

BOSH_CLI_VERSION=${bosh_cli_version}
if [ -z $BOSH_CLI_VERSION ]; then
    BOSH_CLI_VERSION=$$(curl https://s3.amazonaws.com/bosh-cli-artifacts/cli-current-version)
fi

if [ ! -f /bin/bosh ]; then
  sudo wget -O /bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$${BOSH_CLI_VERSION}-linux-amd64
  sudo chmod +x /bin/bosh
fi

wget -O bosh.yml https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/bosh.yml
wget -O cpi.yml https://raw.githubusercontent.com/cloudfoundry/bosh-deployment/master/openstack/cpi.yml

bosh -n create-env bosh.yml -o cpi.yml -l vars.yml --vars-store creds.yml
yq -r .director_ssl.ca creds.yml | grep . > ca_cert
bosh -n -e ${director_ip} --ca-cert ca_cert login --client admin --client-secret $$(yq -r .admin_password creds.yml)
bosh -n -e ${director_ip} --ca-cert ca_cert alias-env ${prefix}
bosh -n -e ${prefix} update-cloud-config cloud-config.yml
