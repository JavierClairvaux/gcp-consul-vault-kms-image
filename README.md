# gcp-consul-vault-kms-image

Vault with Consul backend image for GCP, using Ubuntu 16.04, KMS configuration for autounsealling, to provisiion run:

```Console
$ ./provisioner $NODE_NAME $CONSUL_DC $ENCRYPT_KEY $CONSUL_SERVER_IP $GCP_PROJECT $KEY_LOCATION $KEY_RING $CRYPTO_KEY 
```

To iniitalize Vault with auto-unsealing use:

```Console
$ vault operator init -recovery-shares=1 -recovery-threshold=1
```

To create  image run:
```Console
$ packer build gcp-consul-kms-vault.json 

```
