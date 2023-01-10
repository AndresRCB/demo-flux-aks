# Using Terraform for Deployment
This section shows how to deploy and manage a public AKS cluster using your local console (as long as you have access to Azure and admin rights in your device) and [Terraform](https://www.terraform.io/). Note that while the cluster is public, only your public IP address will be able to reach the cluster's control plane. If your public IP address changes, you will lose access to the control plane, so think of this as a fairly ephemeral cluster (it's for demo purposes after all).

## Prerequisites
- Access to Azure (account and network access)
- A console (bash or zsh in this case) where you have admin rights
- An Azure subscription
- [Terraform CLI](https://www.terraform.io/downloads)
- Registering the Microsoft.Kubernetes, Microsoft.ContainerService and Microsoft.KubernetesConfiguration providers in your Azure subscription (see below for steps to acomplish this)

## Setting up the environment
Once you have an [Azure account](https://azure.microsoft.com/en-us/free/search/), an Azure subscription, and can sign into the [Azure Portal](https://portal.azure.com/), open a console session.

In order to authenticate to Azure from terraform, you'll need to install the Azure CLI. You can install Azure CLI by running the command below in Linux or MacOS, or you can look for [alternatives here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
```sh
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Then, log into your Azure account by running
```sh
az login
```

Once you are in your account, select the subscription with which you want to work.
```sh
## Show available subscriptions
az account show -o table
## Set the subscription you want to use
# az account set -n YOUR_SUBSCRIPTION_NAME
```

Once Azure CLI is authenticated, you'll be able to deploy infrastructure with it and with the Terraform CLI tool, which will use your azure credentials to manage infrastructure.

## Registering the necessary providers in your Azure subscription
Before you continue, register the required providers with the following command:
```sh
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration
```

## Creating the Infrastruture
In this section, we will instruct terraform to create our infrastructure.

### Executing the terraform scripts
First, clone this repository and go into the `terraform/` folder.

```sh
# First navigate to the location where you want this repo.
# Then, run:
git clone https://github.com/andresrcb/demo-flux-aks.git
cd demo-flux-aks/terraform
```

Now that we can execute the terraform commands needed to bring out the Azure infrastructure, we just need to add the necessary parameters to the code via the command line or with a `.tfvars` file. This repository includes a [sample file](/terraform/terraform.tfvars.sample) that can be copied as a starting point.

Now you can plan and apply your infrastructure changes by executing `terraform plan` and`terraform apply` commands.

```sh
terraform plan
# Check your plan and feel free to use it in the next command (we're just running apply as-is)
terraform apply -auto-approve
```

## Connecting to the control plane (using the cluster)
Our cluster has been created as a public cluster, but we can only connect to it from the public IP through which our client machine goes to the internet (client machine being the device that executed `terraform apply`). If you plan on using the same device for creating the infrastructure and then connecting to the cluster, you're good to go; otherwise, you'll have to change the authorized IP ranges for the cluster's control plane.

You only need to install kubectl (if not already installed) and get the cluster context with `az cli`.

```sh
## Install kubectl
sudo az aks install-cli
# Get cluster credentials for kubectl
$(terraform output -raw credentials_command)
```

We're all set now and can use kubectl on our public AKS cluster. To test it, run the following command to get your cluster's kube-system pods:
```sh
kubectl get pods -n kube-system
```

**IMPORTANT**: remember that this cluster will only let you connect to it from the original public IP address from which you executed `terraform apply`. If your client device's public IP address changes for some reason (you move locations or your ISP changes it because it's dynamic), you just need to re-run `terraform apply -auto-approve` so that terraform modifies your control plane to allow connections from your new IP address (keep in mind that your old IP address will be removed from the list of authorized addresses).

# Flux

When the terraform code runs, it will configure a gitops repo for k8s state management. It will also install all flux operators in the AKS cluster and configure them to sync state with the provided git repository. If you leave as-is, this repo will be used for state. To change that, update the terraform variable `gitops_repo_url` with your own, keeping in mind that you need to update the flux configuration to align with your desired repo structure, release strategy, authentication methods, etc.

Check out [Flux](https://fluxcd.io/) and [Azure documentation]((https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli)) to understand what and how to change it. You'll need to update the `azapi_resource.flux_config` resource specifically (and/or add new ones depending on your needs).

Happy kuberneting!