variable "client_id" {}
variable "client_secret" {}

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