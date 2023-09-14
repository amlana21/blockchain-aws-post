

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical owner ID for Ubuntu AMIs
}






resource "tls_private_key" "app_cp_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_public_key" "app_cp_key" {
  algorithm = "RSA"
  rsa_bits = 4096
  private_key_pem = tls_private_key.app_cp_key.private_key_pem
}

resource "aws_key_pair" "app_cp_key" {
  key_name   = "app-cp-instance-key"
  public_key = tls_public_key.app_cp_key.public_key_openssh
}



resource "aws_network_interface" "app_instance_eni" {
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
  
}

resource "aws_instance" "app_instance" {
  ami           = data.aws_ami.ubuntu.id # us-east-1
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = resource.aws_network_interface.app_instance_eni.id
    device_index         = 0
  }
  availability_zone = "us-east-1a"
  key_name = resource.aws_key_pair.app_key.key_name
  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo -u ubuntu touch ~/.bashrc
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | sudo -u ubuntu bash  
  source ~/.bashrc
  export NVM_DIR="$HOME/.nvm"
  sudo [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  source ~/.bashrc
  source ~/.profile
  nvm install 18.17.1
  sudo -u ubuntu [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  source ~/.bashrc
  source ~/.profile
  EOF

  tags= {
    Name = "mainapp"
  }

}