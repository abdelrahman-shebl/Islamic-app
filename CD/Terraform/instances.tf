resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id 
  associate_public_ip_address = true
  security_groups = [aws_security_group.instance_SG.id]
  key_name = aws_key_pair.mykey.key_name

  tags = {
    Name = "instance"
  }
}

resource "null_resource" "ansible_provision" {
  depends_on = [aws_instance.instance]

  provisioner "local-exec" {
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
    command = <<EOT
      ansible-playbook \
        -i '${aws_instance.instance.public_ip},' \
        --private-key ~/.ssh/my-key.pem \
        -u ubuntu \
        ../Ansible/playbook.yml
    EOT
  }
}

# resource "aws_instance" "JS" {
#   ami           = var.ami
#   instance_type = var.JS_type
#   associate_public_ip_address = true
#   subnet_id = aws_subnet.public.id 
#   security_groups = [aws_security_group.JS_SG.id]

#   tags = {
#     Name = "JS"
#   }
# }
