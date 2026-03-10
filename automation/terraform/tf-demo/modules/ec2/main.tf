resource "aws_instance" "example" {

  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "terraform-module-demo"
  }

  # Provisioner example
  provisioner "remote-exec" {

    inline = [
      "echo Hello from Terraform > /tmp/hello.txt"
    ]

  }

  # Overwrite control
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags
    ]
  }

}
