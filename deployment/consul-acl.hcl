# Create policy called le-exporter
# Create a vault consul integration role with 'vault write consul/roles/le-exporter policies="le-exporter"' once created
key_prefix "projects/infrastructure/le" {
  policy = "write"
}

service_prefix "" {
  policy = "read"
}
