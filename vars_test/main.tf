terraform {
  required_providers {
    local = {
      source = "local"
      version = ">= 2.4.0"
    }
  }
}
locals {
  file_out = "item_json.txt"
}
locals {
  items = [
    { name = "123", age = 333, file = "1.txt" },
    { name = "321", age = 12, file = "2.txt"}
  ]
}
variable "items" {
    type=map(any)
    description="Example map variable"
    default={
        "first" = { name = "Mabel", age = 49 },
        "second" = { name = "Andy", age = 52 },
        "third" = { name = "Pete", age = 25 }
    }
}
resource "local_file" "name" {
  for_each = {
    for index, item in local.items:
    item.name => item
  }
  # content = jsonencode(var.items)
  content = templatefile("items.tftpl", { items = var.items})
  filename = "${path.module}/${each.value.file}"
}