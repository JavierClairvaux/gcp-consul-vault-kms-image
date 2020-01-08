#!/bin/bash
#Variables

## Consul variables
node_name=$1
consul_dc=$2
encrypt_key=$3

## Vault variables
server_ip=$4
gcp_project=$5
key_location=$6
key_ring=$7
crypto_key=$8
ip=`hostname -I | tr -d ' '`


sudo sed -i "s/{{NODE}}/${node_name}/g" /etc/consul.d/config.json
sudo sed -i "s/{{DATACENTER}}/${consul_dc}/g" /etc/consul.d/config.json
sudo sed -i "s/{{SERVER_IP}}/${server_ip}/g" /etc/consul.d/config.json
sudo sed -i "s/{{ENCRYPT_KEY}}/${encrypt_key}/g" /etc/consul.d/config.json
sudo sed -i "s/{{IP}}/${ip}/g" /etc/consul.d/config.json
sudo sed -i "s/{{IP}}/${ip}/g" /etc/vault.d/vault.hcl
sudo sed -i "s/{{GCP_PROJECT}}/${gcp_project}/g"  /etc/vault.d/vault.hcl
sudo sed -i "s/{{KEYRING_LOCATION}}/${key_location}/g"  /etc/vault.d/vault.hcl
sudo sed -i "s/{{KEY_RING}}/${key_ring}/g"  /etc/vault.d/vault.hcl
sudo sed -i "s/{{CRIPTO_KEY}}/${crypto_key}/g"  /etc/vault.d/vault.hcl
sleep 5

sudo systemctl start consul
sleep 10
sudo systemctl start vault

#  Run this command to run vault
# export VAULT_ADDR=http://127.0.0.1:8200
