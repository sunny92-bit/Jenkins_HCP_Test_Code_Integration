terraform {
  cloud {
    organization = "SunnyOrg92"

    workspaces {
      name = "Jenkins_HCP_Test_Code_Integration"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-019715e0d74f695be"
  instance_type = "t2.micro"

  tags = {
    Name = "jenkins-terraform-demo-v2"
  }
}