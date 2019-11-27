
provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
}

data "azurerm_resource_group" "resource_group" {
  name                = "thesisGroup"
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    count = 1
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "northeurope"
    resource_group_name = "${data.azurerm_resource_group.resource_group.name}"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    count = 1
    name                 = "mySubnet"
    resource_group_name  = "${data.azurerm_resource_group.resource_group.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork[count.index].name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
count = 1
    name                         = "myPublicIP"
    location                     = "northeurope"
    resource_group_name          = "${data.azurerm_resource_group.resource_group.name}"
    allocation_method            = "Dynamic"
    domain_name_label            = "thesisnode"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    count = 1
    name                = "myNetworkSecurityGroup"
    location            = "northeurope"
    resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    count = 1
    name                      = "myNIC"
    location                  = "northeurope"
    resource_group_name       = "${data.azurerm_resource_group.resource_group.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg[count.index].id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet[count.index].id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip[count.index].id}"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    count = 1
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${data.azurerm_resource_group.resource_group.name}"
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    count = 1
    name                        = "diag${random_id.randomId[count.index].hex}"
    resource_group_name         = "${data.azurerm_resource_group.resource_group.name}"
    location                    = "northeurope"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
count = 1

    name                          = "myVM-${count.index}"
    location                      = "northeurope"
    resource_group_name           = "${data.azurerm_resource_group.resource_group.name}"
    network_interface_ids         = ["${azurerm_network_interface.myterraformnic[count.index].id}"]
    vm_size                       = "Standard_DS1_v2"
    delete_os_disk_on_termination = "true"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "ubuntu"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/ubuntu/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgXBfFArZjcOiDZy25jG/f0By3NgDZAWBdBSZUtXGIARrWHahCGVe8au1rJj5acADmphucTkqXKZq+s6PGGjOSs1V/wXtcVaO/ZdWq8x56qSRBGhoKh879OHKFybsO9R/PfYncOWNeV6Gz+qxGwfHE0CJtvNM7fFQxAQZiAMR8zIwlYH2gdsakpQjJlppYGmeAr+0zgQNfwWwxRqdRUpQEddknbgw3UI8FHxQIXztpyDTk7ySx4KqQVX2q8bZp8xXnm+Dgnm/TZHtMGOHdXxgX314o9UzfSPJkwZcu+Xynr5vRBPyyBOB7cbYfv5CHC9wki75IWa/CVVvuVUIGE+opw=="
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount[count.index].primary_blob_endpoint}"
    }

    tags = {
        environment = "Terraform Demo"
    }
    
    connection {
      host        = "thesisnode.northeurope.cloudapp.azure.com"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("D:\\Tools\\Keys\\azureThesis.pem")}"
      timeout     = "1m"
    }


    provisioner "remote-exec" {

      inline = [
          "sleep 20",
          "date >> provisionedAt.txt",
          "sudo echo ${var.key_data} >> /home/ubuntu/.ssh/authorized_keys",
          "export myIP=$(curl -H Metadata:true \"http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-04-02&format=text\")",
          #"curl --retry 5 -m 120 -X GET '${var.registrationAPI}?ipAddress=${IPAddress.value}&cmTool=Ansible&testSuite=4'"
          "curl --retry 5 -m 120 -X GET \"${var.registrationAPI}?ipAddress=$myIP&cmTool=Ansible&testSuite=4\""
    ]
  }


}

data "azurerm_public_ip" "myterraformpublicip" {
count = 1
  name                = "${azurerm_public_ip.myterraformpublicip[count.index].name}"
  resource_group_name = "${azurerm_virtual_machine.myterraformvm[count.index].resource_group_name}"
}

#"curl --retry 5 -m 120 -X GET '${var.registrationAPI}?ipAddress=${azurerm_public_ip.myterraformpublicip[count.index].ip_address}&cmTool=Ansible&testSuite=4'"

output "IPAddress" {
  value = "${data.azurerm_public_ip.myterraformpublicip.*.ip_address}"
}
