# Kelomai: Azure Operatoins Toolkit

Welcome to **Kelomai**, your go-to toolkit for automating Azure resource management using **PowerShell Core** and the **Azure CLI (az cli)**. This repository is designed to simplify your Azure DevOps workflows by providing reusable, real-world script examples.

## Why Kelomai?

Scripting is the key to ensuring consistent environments and reducing human error. Kelomai provides a growing library of **PowerShell Core** scripts that leverage the **Azure CLI** to help you manage Azure resources efficiently. Instead of figuring out commands from scratch, you can use these examples to accelerate your automation tasks.

Our goal is to provide practical, real-world examples that you can adapt to your needs. While Microsoft offers an extensive [Azure CLI reference](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest), Kelomai focuses on actionable examples to get you started quickly.

## Install the Azure CLI

The Azure CLI is a powerful, cross-platform tool for managing Azure resources. It can be installed on Windows, macOS, Linux, or even run in a Docker container.

Visit the [install page](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) to get started.

## Kelomai Administrator's VM

Check out our [one-click Azure administrator VM](https://github.com/Build5Nines/az-kung-fu-vm). This VM comes pre-installed with tools like Azure CLI, Visual Studio Code, and more, making it easy to get started with Kelomai.

Deploy the VM by clicking this button:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FBuild5Nines%2Faz-kung-fu-vm%2Fmaster%2Fazure-deploy.json" target="_blank">
    <img src="https://github.com/Build5Nines/az-kung-fu-vm/raw/master/media/Deploy-to-Azure-button.png"/>
</a>

Once provisioned, you'll have everything you need to master Azure CLI automation with Kelomai.

## PowerShell Core, Visual Studio Code & Azure CLI

All scripts in this repository are written in **PowerShell Core** and use the **Azure CLI** for executing commands. To run these scripts, ensure you have the following installed:

- [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.2)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Visual Studio Code](https://code.visualstudio.com/) with the [Azure CLI Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli)

Visual Studio Code provides IntelliSense for Azure CLI commands and allows you to run scripts directly from the integrated terminal.

![CODECLI](https://github.com/Microsoft/vscode-azurecli/raw/master/images/in_action.gif)

## Folders

The repository is organized into folders based on Azure resource types, such as Compute, Storage, Networking, or Containers. Each folder contains sample scripts for managing specific resources.

For example, to work with virtual networks (`az network vnet`), navigate to:

```
/network/vnet
```

## File Naming Convention

Scripts are named based on the resource type (noun) and the action (verb). For example:

- To create a virtual network:  
  `/network/vnet/create/vnet-create.azcli`

- To update a virtual network with custom DNS settings:  
  `/network/vnet/update/vnet-update-dns.azcli`

- To delete a virtual network:  
  `/network/vnet/delete/vnet-delete.azcli`

## Running Scripts

Before running any scripts, authenticate with your Azure subscription using:

```
az login
```

## FAQ

### Can I contribute?

Yes! Contributions are welcome. Submit a Pull Request with your scripts or improvements. See our [Contribution Guide](CONTRIBUTE.md) for details.

### Can I use this code?

Yes, Kelomai is released under the MIT License. See the LICENSE file for details.

### Do you have Bash versions of these scripts?

No, all scripts are written in PowerShell Core. However, you can adapt them for Bash if needed.

### I'm having an issue with a script.

Submit an issue on the project's GitHub Issues tab.

### Do you offer training?

Not yet, but we plan to release a training course soon.

---

Thank you for using Kelomai! We hope it helps you streamline your Azure automation workflows.