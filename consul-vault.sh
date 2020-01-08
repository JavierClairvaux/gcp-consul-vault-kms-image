#!/bin/bash

sudo apt update -y
sudo apt install unzip -y
sudo apt install dnsmasq -y

# Install consul
sudo wget -q https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip 
sudo unzip  consul_1.6.1_linux_amd64.zip
sudo rm -f  consul_1.6.1_linux_amd64.zip
sudo chmod +x consul
sudo mv consul /usr/local/bin
sudo mkdir -p /etc/consul.d/scripts

  # creating consul user
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir -p /opt/consul
sudo chown --recursive consul:consul /opt/consul

# SYSTEM D
echo '[Unit]
Description="HashiCorp Consul Agent"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/config.json

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/ -enable-local-script-checks
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/consul.service

echo '{
  "server": false,
  "node_name" : "{{NODE}}",
  "bind_addr": "0.0.0.0",
  "datacenter": "{{DATACENTER}}",
  "data_dir": "/opt/consul",
  "domain": "consul",
  "enable_script_checks": true,
  "enable_syslog": true,
  "encrypt": "{{ENCRYPT_KEY}}",
  "leave_on_terminate": true,
  "log_level": "DEBUG",
  "rejoin_after_leave": true,
  "advertise_addr": "{{IP}}",
  "start_join": [
      "{{SERVER_IP}}"
  ],
  "ports": {
      "grpc" : 8502
     }
}' | sudo tee /etc/consul.d/config.json





# dns masq update
# Netmask
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

sudo rm /etc/resolv.conf
echo "
  nameserver 127.0.0.1
  nameserver 8.8.8.8
" | sudo tee /etc/resolv.conf;

# creating consul dnsmasq
# disabling
echo "
# Forwarding lookup of consul domain
server=/consul/127.0.0.1#8600
" | sudo tee /etc/dnsmasq.d/10-consul

sudo systemctl restart dnsmasq

cd /usr/local/bin
sudo wget -q https://releases.hashicorp.com/vault/1.2.4/vault_1.2.4_linux_amd64.zip
sudo unzip vault_1.2.4_linux_amd64.zip
sudo rm vault_1.2.4_linux_amd64.zip
chmod +x vault
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
sudo useradd --system --home /etc/vault.d --shell /bin/false vault
echo '[Unit]
Description=Vault secret management tool
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
PIDFile=/var/run/vault/vault.pid
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl -log-level=debug
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/vault.service

sudo systemctl daemon-reload
sudo mkdir --parents /etc/vault.d
#sudo cp /vagrant/vault/$clientfolder/vault.hcl /etc/vault.d/vault.hcl
echo 'listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "{{IP}}:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

seal "gcpckms" {
  project     = "{{GCP_PROJECT}}"
  region      = "{{KEYRING_LOCATION}}"
  key_ring    = "{{KEY_RING}}"
  crypto_key  = "{{CRIPTO_KEY}}"
}

api_addr = "http://{{IP}}:8200"
cluster_addr = "https://{{IP}}:8201"
' | sudo tee /etc/vault.d/vault.hcl

sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl

echo  'export VAULT_ADDR="http://127.0.0.1:8200"' >> ~/.profile 
