variable "client_id" {default = "127374e2-fcf5-4ef2-af8e-bb368e17dd97"}
variable "client_secret" {default = "669a4926-ae7e-4403-8208-fc629452506d"}

variable "agent_count" {
    default = 1
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "ca1-AKS-Cluster"
}

variable cluster_name {
    default = "ca1-AKS-Cluster"
}

variable resource_group_name {
    default = "ca1-resource-group"
}

variable location {
    default = "North Europe"
}

variable log_analytics_workspace_name {
    default = "EADLogAnalyticsWorkspaceNameDH"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "northeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}