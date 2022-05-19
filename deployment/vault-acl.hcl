#Create a policy called le-exporter
path "consul/creds/le-exporter" {  
	capabilities = ["read"]
}

path "kv/data/projects/system/le-exporter" {  
	capabilities = ["read"]
}

path "kv/data/infrastructure/le-certs/*" {  
	capabilities = ["read", "create", "update", "delete"]
}

path "kv/metadata/infrastructure/le-certs" {  
	capabilities = ["list"]
}
