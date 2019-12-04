# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"
provider "aws" {
  region = "eu-west-1"
}

variable "configTool" {
  default = "puppet"   # salt, puppet, ansible 
}


# used for Amazon Linux
locals  {
  instance-userdata = <<EOF
#! /bin/bash -x
date >> /provisionedAt.txt
sudo apt-get update
sudo apt-get -y install awscli > /output.log 2>&1
git clone https://github.com/RedXIV2/terraform.git
sudo bash /terraform/scripts/setupBaseFiles.sh
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible >> /output.log 2>&1
sudo sed -i '/callback_whitelist/c\callback_whitelist = profile_tasks' /etc/ansible/ansible.cfg
sudo sed -i '/host_key_checking/c\host_key_checking = False' /etc/ansible/ansible.cfg
sudo sed -i '/#remote_user/c\remote_user = ubuntu' /etc/ansible/ansible.cfg
sudo sed -i '/#private_key_file/c\private_key_file = /tmp/awsthesis.pem' /etc/ansible/ansible.cfg
ls /tmp >> /didKeyArrive.txt
echo '# Check if the ssh-agent is already running' >> /home/ubuntu/.bashrc
echo 'if [[ "$(ps -u $USER | grep ssh-agent | wc -l)" -lt "1" ]]; then' >> /home/ubuntu/.bashrc
echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent will be started"' >> /home/ubuntu/.bashrc
echo '  # Start the ssh-agent and redirect the environment variables into a file' >> /home/ubuntu/.bashrc
echo '    ssh-agent -s >~/.ssh/ssh-agent' >> /home/ubuntu/.bashrc
echo '    # Load the environment variables from the file' >> /home/ubuntu/.bashrc
echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ubuntu/.bashrc
echo '    # Add the default key to the ssh-agent' >> /home/ubuntu/.bashrc
echo '    chmod 400 /tmp/awsthesis.pem' >> /home/ubuntu/.bashrc
echo '    ssh-add /tmp/awsthesis.pem' >> /home/ubuntu/.bashrc
echo 'else' >> /home/ubuntu/.bashrc
echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent already running"' >> /home/ubuntu/.bashrc
echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ubuntu/.bashrc
echo 'fi' >> /home/ubuntu/.bashrc
  EOF
  }

# used for Amazon Linux
locals  {
  instance-userdata3 = <<EOF
#! /bin/bash -x
date >> /provisionedAt.txt
sudo apt-get update
sudo apt-get -y install awscli > /output.log 2>&1
git clone https://github.com/RedXIV2/terraform.git
sudo bash /terraform/scripts/setupBaseFiles.sh "${var.configTool}"
ls /tmp >> /didKeyArrive.txt
echo '# Check if the ssh-agent is already running' >> /home/ubuntu/.bashrc
echo 'if [[ "$(ps -u $USER | grep ssh-agent | wc -l)" -lt "1" ]]; then' >> /home/ubuntu/.bashrc
echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent will be started"' >> /home/ubuntu/.bashrc
echo '  # Start the ssh-agent and redirect the environment variables into a file' >> /home/ubuntu/.bashrc
echo '    ssh-agent -s >~/.ssh/ssh-agent' >> /home/ubuntu/.bashrc
echo '    # Load the environment variables from the file' >> /home/ubuntu/.bashrc
echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ubuntu/.bashrc
echo '    # Add the default key to the ssh-agent' >> /home/ubuntu/.bashrc
echo '    chmod 400 /tmp/awsthesis.pem' >> /home/ubuntu/.bashrc
echo '    ssh-add /tmp/awsthesis.pem' >> /home/ubuntu/.bashrc
echo 'else' >> /home/ubuntu/.bashrc
echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent already running"' >> /home/ubuntu/.bashrc
echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ubuntu/.bashrc
echo 'fi' >> /home/ubuntu/.bashrc
  EOF
  }

# Used for Ubuntu
locals {
  instance-userdata2 = <<EOF
  #! /bin/bash
  date >> provisionedAt.txt
  ls /tmp >> didKeyArrive.txt
  echo '# Check if the ssh-agent is already running' >> /home/ubuntu/.bashrc
  echo 'if [[ "$(ps -u $USER | grep ssh-agent | wc -l)" -lt "1" ]]; then' >> /home/ubuntu/.bashrc
  echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent will be started"' >> /home/ubuntu/.bashrc
  echo '  # Start the ssh-agent and redirect the environment variables into a file' >> /home/ubuntu/.bashrc
  echo '    ssh-agent -s >~/.ssh/ssh-agent' >> /home/ubuntu/.bashrc
  echo '    # Load the environment variables from the file' >> /home/ubuntu/.bashrc
  echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ubuntu/.bashrc
  echo '    # Add the default key to the ssh-agent' >> /home/ubuntu/.bashrc
  echo '    chmod 400 /tmp/awsthesis.pem' >> /home/ubuntu/.bashrc
  echo '    ssh-add /tmp/awsthesis.pem' >> /home/ubuntu/.bashrc
  echo 'else' >> /home/ubuntu/.bashrc
  echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent already running"' >> /home/ubuntu/.bashrc
  echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ubuntu/.bashrc
  echo 'fi' >> /home/ubuntu/.bashrc
  EOF
}


data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

  owners = ["amazon"] 
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
owners = ["099720109477"]
}

resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"

ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 0
    to_port = 0
    protocol = "-1"
  
  }  
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

}
resource "aws_instance" "web" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     =  "t2.medium" #"t2.micro"
  key_name          = "awsthesis"
  iam_instance_profile  = "configMaster"
  security_groups = ["${aws_security_group.ingress-all-test.name}"]
  
  tags = {
    Name = "ConfigMaster"
  }

  connection {
    host = "${aws_instance.web.public_ip}"
    type = "ssh"
    #user = "ec2-user"
    user = "ubuntu"
    private_key = "${file("D:\\Tools\\Keys\\awsthesis.pem")}"
    agent = false
  }

  provisioner "file" {
    source      = "D:\\Tools\\Keys\\awsthesis.pem"
    destination = "/tmp/awsthesis.pem"
  }

  user_data = "${local.instance-userdata3}"
  #user_data_base64  = "${base64encode(local.instance-userdata)}"
}