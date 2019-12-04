# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"
provider "aws" {
  region = "eu-west-1"
}

locals  {
  instance-userdata2 = <<EOF
#! /bin/bash
date >> provisionedAt.txt
EOF
  }

locals  {
  instance-userdata = <<EOF
#! /bin/bash
date >> provisionedAt.txt
sudo apt install -y awscli
sudo apt install -y python
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

resource "aws_instance" "web" {
count = 3

  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "t2.micro"
  key_name          = "awsthesis"
  user_data_base64  = "${base64encode(local.instance-userdata)}"
  iam_instance_profile  = "configMaster"

  tags = {
    Name = "test-server-${count.index}"
  }

  connection {
    #host = "${aws_instance.web[count].public_ip}"
    host = "${self.public_ip}"
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("D:\\Tools\\Keys\\awsthesis.pem")}"
    agent = false
  }

  provisioner "remote-exec" {
      inline = [
        "sudp apt-get update",
        "sudo git clone https://github.com/RedXIV2/terraform.git /terraform",
        "sudo cp /terraform/scripts/addToFamily/addTo* /",
        "sudo chmod 777 /addTo*",
        "curl --retry 5 -m 120 -X GET '${var.registrationAPI}?ipAddress=${self.private_ip}&cmTool=Salt&testSuite=2&platform=aws'"
      ]
  }


}