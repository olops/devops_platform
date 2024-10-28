
output "service" {
  value = data.kubernetes_service_v1.postgresql.metadata[0].name
}

output "service_port" {
  value = data.kubernetes_service_v1.postgresql.spec[0].port[0].port
}
