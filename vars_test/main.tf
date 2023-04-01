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
# locals {
  # items = {
    # file1 = { name ="1.txt" }
    # file2 = { name = "2.txt" }
    # file3 = { name = "3.txt" }
  # }
# }
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
  # for_each = toset(var.items)
  for_each = {
    for index, item in local.items:
    item.name => item
  }
  # content = jsonencode(var.items)
  content = templatefile("items.tftpl", { items = var.items})
  filename = "${path.module}/${each.value.file}"
  # dynamic "ffil" {
    # for_each = local.items
    # content {
      # filename = "${path.module}/${ffil.value.name}"
    # }
  # }
}

variable "testout" {
  description = "test out list in for operation"
  type = list(string)
  default = ["test1", "test2", "test3"]
}
output "outtest" {
  value = [for out in var.testout: upper(out)]
}
variable "maptestout" {
  description = "map test out"
  type = map(string)
  default = {
    "Key1" = "ValMap2",
    "Key2" = "ValMap3"
  }
}
output "mapout" {
  value = [for Key, Val in var.maptestout: "${Key} is Value by ${Val}"]
}