
provider "aws" {
  profile    = "default"
  region     = "ap-southeast-1"
}
resource "aws_key_pair" "example" {
  key_name = "examplekey"
  public_key = file("./ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  key_name = aws_key_pair.example.key_name
  ami           = "ami-061eb2b23f9f8839c"
  instance_type = "t3.nano"

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