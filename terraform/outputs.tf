output "internal_ip_address_web1" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}

output "internal_ip_address_web2" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}

output "internal_ip_address_elastic" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}

output "internal_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
output "external_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "internal_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}
output "external_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "internal_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}
output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "external_ip_address_load_balancer" {
  value = yandex_alb_load_balancer.load_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

# Вывод в файл host для ansible

resource "local_file" "ansible_host_file" {
  content  = <<-EOT
    [balancer]
    ${yandex_alb_load_balancer.load_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}

    [netology:children]
    bastion
    web
    zabbix
    elastic
    kibana

    [bastion]
    ${yandex_compute_instance.bastion.fqdn} public_ip=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} 
    
    [web]
    ${yandex_compute_instance.web1.fqdn} 
    ${yandex_compute_instance.web2.fqdn}

    [zabbix]
    ${yandex_compute_instance.zabbix.fqdn} public_ip=${yandex_compute_instance.zabbix.network_interface.0.nat_ip_address} 

    [elastic]
    ${yandex_compute_instance.elastic.fqdn}

    [kibana]
    ${yandex_compute_instance.kibana.fqdn} public_ip=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} 
    
    [netology:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -p 22 -W %h:%p -q vyach@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
    EOT
  filename = "/home/vyach/sys-diplom/ansible/hosts"
}