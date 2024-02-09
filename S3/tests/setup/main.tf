resource "random_pet" "this" {
  length = 2
}

output "random_pet" {
  value = random_pet.this.id
}
