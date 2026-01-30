output "vpc_id" {
  description = "VPC network ID"
  value       = yandex_vpc_network.diploma-vpc.id
}

output "subnet_a_id" {
  description = "Subnet A ID (ru-central1-a)"
  value       = yandex_vpc_subnet.subnet-a.id
}

output "subnet_b_id" {
  description = "Subnet B ID (ru-central1-b)"
  value       = yandex_vpc_subnet.subnet-b.id
}

output "subnet_d_id" {
  description = "Subnet D ID (ru-central1-d)"
  value       = yandex_vpc_subnet.subnet-d.id
}
