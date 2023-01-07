output "api_server_authorized_ip_ranges" {
  value       = module.public_aks_cluster.api_server_authorized_ip_ranges
  description = "CIDR range of IP addresses that can access the cluster's API server's public endpoint"
}

output "cluster_name" {
  value       = module.public_aks_cluster.name
  description = "Name of the kubernetes cluster created by the aks-public-module"
}

output "credentials_command" {
  value       = module.public_aks_cluster.credentials_command
  description = "Command to get the cluster's credentials with az cli"
}

output "invoke_command" {
  value       = module.public_aks_cluster.invoke_command
  description = "Sample command to execute k8s commands on the cluster using az cli"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Name of the resource group where the cluster was created"
}
