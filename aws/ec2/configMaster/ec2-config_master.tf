# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"
provider "aws" {
  region = "eu-west-1"
}

locals  {
  instance-userdata = <<EOF
  #! /bin/bash
  date >> provisionedAt.txt
  sudo yum -y install git
  git clone https://github.com/RedXIV2/terraform.git 
  sudo bash terraform/scripts/setupBaseFiles.sh
  sudo yum-config-manager --enable epel > output.log 2>&1
  sleep 20
  sudo yum -y install ansible >output.log 2>&1
  sudo sed -i '/callback_whitelist/c\callback_whitelist = profile_tasks' /etc/ansible/ansible.cfg
  sudo sed -i '/host_key_checking/c\host_key_checking = False' /etc/ansible/ansible.cfg
  sudo sed -i '/#remote_user/c\remote_user = ec2-user' /etc/ansible/ansible.cfg
  sudo sed -i '/#private_key_file/c\private_key_file = /tmp/awsthesis.pem' /etc/ansible/ansible.cfg
  ls /tmp >> didKeyArrive.txt
  echo '# Check if the ssh-agent is already running' >> /home/ec2-user/.bashrc
  echo 'if [[ "$(ps -u $USER | grep ssh-agent | wc -l)" -lt "1" ]]; then' >> /home/ec2-user/.bashrc
  echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent will be started"' >> /home/ec2-user/.bashrc
  echo '  # Start the ssh-agent and redirect the environment variables into a file' >> /home/ec2-user/.bashrc
  echo '    ssh-agent -s >~/.ssh/ssh-agent' >> /home/ec2-user/.bashrc
  echo '    # Load the environment variables from the file' >> /home/ec2-user/.bashrc
  echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ec2-user/.bashrc
  echo '    # Add the default key to the ssh-agent' >> /home/ec2-user/.bashrc
  echo '    chmod 400 /tmp/awsthesis.pem' >> /home/ec2-user/.bashrc
  echo '    ssh-add /tmp/awsthesis.pem' >> /home/ec2-user/.bashrc
  echo 'else' >> /home/ec2-user/.bashrc
  echo '    #echo "$(date +%F@%T) - SSH-AGENT: Agent already running"' >> /home/ec2-user/.bashrc
  echo '    . ~/.ssh/ssh-agent >/dev/null' >> /home/ec2-user/.bashrc
  echo 'fi' >> /home/ec2-user/.bashrc
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

resource "aws_instance" "web" {
  ami               = "${data.aws_ami.amazon_linux.id}"
  instance_type     = "t2.micro"
  key_name          = "awsthesis"
  iam_instance_profile  = "configMaster"
  
  tags = {
    Name = "ConfigMaster"
  }

  connection {
    host = "${aws_instance.web.public_ip}"
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("D:\\Tools\\Keys\\awsthesis.pem")}"
    agent = false
  }

  provisioner "file" {
    source      = "D:\\Tools\\Keys\\awsthesis.pem"
    destination = "/tmp/awsthesis.pem"
  }

  user_data_base64  = "${base64encode(local.instance-userdata)}"
}