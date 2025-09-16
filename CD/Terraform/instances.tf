resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id 
  associate_public_ip_address = true
   root_block_device {
    volume_size           = 20   # size in GB
    volume_type           = "gp3"  
    delete_on_termination = true
  }
  security_groups = [aws_security_group.instance_SG.id]
  key_name = aws_key_pair.mykey.key_name

  tags = {
    Name = "instance"
  }
}

resource "null_resource" "wait_for_ssh" {
  provisioner "local-exec" {
    command = <<EOT
      until nc -zv ${aws_instance.instance.public_ip} 22; do sleep 5; done
    EOT
  }
}

resource "null_resource" "ansible_provision" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
    command = <<EOT
      ansible-playbook  \
        -i '${aws_instance.instance.public_ip},' \
        --private-key ~/.ssh/my-key.pem \
        -e "ansible_user=ubuntu"  \
        -e "alb_dns=${aws_lb.my_alb.dns_name}" \
        --ask-vault-pass \
        ../Ansible/playbook.yml
    EOT
  }
}



# resource "null_resource" "ansible_provision" {
#   depends_on = [aws_instance.instance]

#   provisioner "local-exec" {
#     environment = {
#       ANSIBLE_HOST_KEY_CHECKING = "False"
#     }
#     command = <<EOT
#       ansible-playbook \
#         -i '${aws_instance.instance.public_ip},' \
#         --private-key ~/.ssh/my-key.pem \
#         -u ubuntu \
#         ../Ansible/playbook.yml
#     EOT
#   }
# }

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
