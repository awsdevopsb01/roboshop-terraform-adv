locals {
  db_commands = [
    "rm -rf roboshop-adv-shell",
    "git clone https://github.com/awsdevopsb01/roboshop-adv-shell.git",
    "cd roboshop-adv-shell",
    "sudo bash ${var.component_name}.sh"
  ]

  app_commands = [
    "sudo labauto ansible",
    "ansible-pull -i localhost, -U https://github.com/awsdevopsb01/roboshop-ansible.git roboshop.yml -e role_name=${var.component_name}"
  ]

  db_tags = {
    Name  = "${var.component_name}"
  }
  app_tags = {
    Name  = "${var.component_name}"
    Monitor = "true"
    component = var.component_name
  }
}