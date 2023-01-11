resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "public_aks_cluster" {
  source = "github.com/AndresRCB/aks-public-cluster"

  resource_group_name = azurerm_resource_group.main.name
  
  depends_on = [
    azurerm_resource_group.main
  ]
}

resource "azapi_resource" "flux_addon" {
  type       = "Microsoft.KubernetesConfiguration/extensions@2022-11-01"
  name       = "flux"
  parent_id  = module.public_aks_cluster.id
  locks      = [module.public_aks_cluster.id]
  body = jsonencode({
    properties = {
      extensionType           = "microsoft.flux"
      autoUpgradeMinorVersion = true
    }
  })

  timeouts {
    create = "20m"
  }
}

resource "azapi_resource" "flux_config" {
  type      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2022-11-01"
  name      = "cluster-config"
  parent_id = module.public_aks_cluster.id

  depends_on = [
    azapi_resource.flux_addon
  ]

  body = jsonencode({
    properties = {
      scope      = "cluster"
      namespace  = "cluster-config"
      sourceKind = "GitRepository"
      suspend    = false
      gitRepository = {
        url                   = var.gitops_repo_url
        timeoutInSeconds      = 120
        syncIntervalInSeconds = 120
        repositoryRef = {
          branch = var.gitops_branch_name
        }
        # httpsUser = var.gitops_https_user
      }
    #   configurationProtectedSettings = {
    #     httpsKey = sensitive(base64encode(var.gitops_https_password))
    #   }
      kustomizations = {
        infrastructure = {
          path                   = "cluster-config/infrastructure"
          timeoutInSeconds       = 600
          syncIntervalInSeconds  = 60
          retryIntervalInSeconds = 60
          prune                  = true
          force                  = true
        }
        apps = {
          path                   = "cluster-config/apps/staging"
          dependsOn              = ["infrastructure"]
          timeoutInSeconds       = 600
          syncIntervalInSeconds  = 60
          retryIntervalInSeconds = 60
          prune                  = true
          force                  = true
        }
      }
    }
  })
}