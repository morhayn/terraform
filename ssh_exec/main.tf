terraform {
  required_providers {
    null = {
      source = "local"
      version = ">= 3.2.1"
    }
  }
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
resource "null_resource" "name" {
  for_each = {
    for index, host in locals.hosts:
    host.name => host
  }
  connection {
    type = "ssh"
    user = "user"
    password = var.root_password
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