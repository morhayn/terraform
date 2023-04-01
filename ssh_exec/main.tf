terraform {
  required_providers {
    null = {
      source = "null"
      version = ">= 3.2.1"
    }
    local = {
      source = "local"
      version = ">= 2.4.0"
    }
  }
}
variable "user_password" {
  description = "Password user for execute remote ssh command"
  type = string
}

locals {
  hosts = [
    { name = "web", ip = "10.0.0.10", files = [
      {src = "templ/nginx.conf", dest = "/etc/nginx/"},
      {src = "templ/conf.d/site.conf", dest = "/etc/nginx/conf.d/"}
    ], commands = [
      "dnf install nginx",
      "systemctl enable --now nginx",
    ]},
    { name = "db", ip = "10.0.0.15", files =[
      {src = "templ/mongod.conf", dest = "/etc/mongod/"}
    ], commands = [
      "apt install mongod",
      "systemctl enable --now mongod"
    ] }
  ]
}
resource "null_resource" "sshcmd" {
  for_each = {
    for index, host in locals.hosts:
    host.name => host
  }
  connection {
    type = "ssh"
    user = "user"
    password = var.user_password
    host = each.host.ip
  }
  provisioner "file" {
    for_each = {
      for index, file in each.host.files:
      file.name => file
    }
    source = each.file.src
    destination = each.file.dest
  }
  provisioner "remote-exec" {
    inline = each.host.commands
  }
}
# variable "hosts" {
  # type = list(map(string))
# }
# hosts = [
  # {
    # name = "web"
    # ip = "10.0.0.10"
    # files = [
      # {src = "templ/nginx.conf", dest = "/etc/nginx/"},
      # {src = "templ/conf.d/site.conf", dest = "/etc/nginx/conf.d/"}
    # ]
    # commands = [
      # "dnf install nginx",
      # "systemctl enable --now nginx",
    # ]
  # }
# ]
# resource "null_resource" "sshcmd2" {
  # for_each = var.hosts
  # connection {
    # type = "ssh"
    # user = "user"
    # password = var.user_password
    # ip = each.value.ip
  # }
  # provisioner "file" {
    # for_each = each.value.files
    # source = each.file.src
    # destination = each.file.dest
  # }
  # provisioner "remote-exec" {
    # inline = each.value.commands
  # } 
# }