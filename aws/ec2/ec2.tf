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
count = 5

  ami               = "${data.aws_ami.amazon_linux.id}"
  instance_type     = "t2.micro"
  key_name          = "awsthesis"
  user_data_base64  = "${base64encode(local.instance-userdata)}"

  tags = {
    Name = "test-server-${count.index}"
  }

  connection {
    #host = "${aws_instance.web[count].public_ip}"
    host = "${self.public_ip}"
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("D:\\Tools\\Keys\\awsthesis.pem")}"
    agent = false
  }

  provisioner "remote-exec" {
      inline = [
        "curl --retry 5 -X GET '${var.registrationAPI}?ipAddress=${self.private_ip}&cmTool=Ansible&testSuite=1'"
      ]
  }


}