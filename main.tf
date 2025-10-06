provider "aws" {
  region = "me-central-1" # Set your desired AWS region
}

data "aws_vpc" "existing-vpc" { # calling existing-vpc named DEV-VPC
  filter {
    name   = "tag:Name"
    values = ["DEV-VPC"]
  }
}

data "aws_subnet" "existing-DevVpc-Pub-subnet" { # calling existing one of DEV-VPC public subnet named DEV-VPC-PUB-SUBNET2
  id = "subnet-071d36680b1e6071c"
}

data "aws_security_group" "MyIP_Access" { # calling existing security group named MYIP_ACCESS
  name   = "MyIP-Access"
  vpc_id = "vpc-038eeb9c3bb84d366"

}
resource "aws_instance" "web" {
  ami           = "ami-0e800f53613913cef" # Specify an appropriate AMI ID
  instance_type = "t3.micro"
  key_name      = "UAE"
  # Refer to existing-DevVpc-Pub-Subnet
  subnet_id                   = data.aws_subnet.existing-DevVpc-Pub-subnet.id
  vpc_security_group_ids      = [data.aws_security_group.MyIP_Access.id]
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-EC2-web"
  }
}
output "public_ip" {
  value = aws_instance.web.public_ip
}
