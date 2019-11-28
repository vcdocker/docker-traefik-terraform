
provider "aws" {
  profile    = "default"
  region     = "ap-southeast-1"
}

variable "ssh_key_name" {
  default     = ""
  description = "Amazon AWS Key Pair Name"
}

variable "instance_type" {
  default     = "t3.nano"
  description = "Amazon AWS EC2 Instance Type"
}

variable "ami" {
  default     = "ami-061eb2b23f9f8839c"
  description = "Amazon AWS EC2 Image"
}

resource "aws_key_pair" "ssh_key" {
  key_name = var.ssh_key_name
  public_key = file("./ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  key_name = var.ssh_key_name
  ami           = var.ami
  instance_type = var.instance_type

 connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("./ssh/id_rsa")
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install git",
      "curl -sL https://raw.githubusercontent.com/vcdocker/vcrobot-server-setup/master/install/docker/19.03.sh | sh",
      "sudo usermod -aG docker $USER",
      "sudo systemctl enable docker"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sL https://raw.githubusercontent.com/vcdocker/vcrobot-server-setup/master/init.sh | sh"
    ]
  }
}

output "ip" {
  value = aws_instance.web.public_ip
}