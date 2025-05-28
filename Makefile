SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

## Default environment name (not strictly used here, but kept for possible future use)
ENV ?= local

## Help
help:
	@echo "📦 Azure Static Web - Terraform Local Deployment"
	@echo ""
	@echo "Available commands:"
	@echo "  make az-login         - Login to Azure CLI"
	@echo "  make tf-init          - Initialize Terraform (local state)"
	@echo "  make tf-plan          - Run Terraform plan"
	@echo "  make tf-apply         - Apply Terraform plan"
	@echo "  make tf-destroy       - Destroy infrastructure"
	@echo "  make clean            - Remove .terraform and tfplan"
	@echo ""

## Azure CLI login
az-login:
	@echo "🔐 Logging in to Azure..."
	az login
	az account show

az-sub-id:
    $(eval ARM_SUBSCRIPTION_ID = $(shell az account show --query id -o tsv))

## Terraform commands
tf-init:
	@echo "🚀 Initializing Terraform (local backend)..."
	terraform init -upgrade
	terraform validate

tf-plan: az-sub-id
	@echo "📐 Formatting and validating..."
	terraform fmt --recursive
	terraform validate
	@echo "📝 Running terraform plan..."
	terraform plan -out=tfplan

tf-apply:
	@echo "🚀 Applying Terraform plan..."
	terraform apply -auto-approve tfplan

tf-destroy:
	@echo "🔥 Destroying all Terraform-managed infrastructure..."
	terraform destroy -auto-approve

## Cleanup
clean:
	@echo "🧹 Cleaning up local Terraform state..."
	rm -rf .terraform tfplan terraform.tfstate terraform.tfstate.backup
