resource "aws_instance" "ec2_module_demo" {

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = "terraform-module-demo"
  }

  # Overwrite control
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags
    ]
  }
}

# Provisioner example
resource "null_resource" "provisioner" {

  count = var.enable_provisioner ? 1 : 0

  provisioner "remote-exec" {

    inline = [
      "echo Terraform Provisioner Running"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.key_path)
      host        = aws_instance.ec2_module_demo.public_ip
    }

  }

}