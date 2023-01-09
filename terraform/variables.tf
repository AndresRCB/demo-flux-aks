variable "gitops_repo_url" {
  type = string
  description = "URL of the git repo to use for GitOps for this demo cluster"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group to create the cluster in"
}

variable "gitops_branch_name" {
  type = string
  description = "Branch with which configuration will be synced"
  default = "main"
}

variable "location" {
  type        = string
  description = "Location of Azure region for all resources to be used"
  default     = "eastus"
}

variable "cluster_dns_prefix" {
  type        = string
  description = "DNS prefix for AKS cluster"
  default     = "fluxdemo"
}

variable "cluster_name" {
  type        = string
  description = "Name for the public AKS cluster"
  default     = "cluster-flux-demo"
}

variable "cluster_sku_tier" {
  type        = string
  description = "SKU tier selection between Free and Paid"
  default     = "Free"
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the created resources"
  default     = {}
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network where all resources will be"
  default     = "vnet-flux-demo"
}
