# Виртуальные машины для веб сервера

resource "yandex_compute_instance" "web1" {
  name = "web1"
  hostname = "web1-vm"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 4
  }

#  scheduling_policy {
#    preemptible = true
#  }

  boot_disk {
    initialize_params {
      image_id = "fd89dg1rq7uqslc6eigm"
      block_size = 4096
      size = 10
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_web1.id
    security_group_ids = [yandex_vpc_security_group.main_group.id]
  }

  metadata = {
    user-data = "${file("/home/vyach/sys-diplom/terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "web2" {
  name = "web2"
  hostname = "web2-vm"
  platform_id = "standard-v3"
  zone = "ru-central1-b"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 4
  }

#  scheduling_policy {
#    preemptible = true
#  }

  boot_disk {
    initialize_params {
      image_id = "fd89dg1rq7uqslc6eigm"
      block_size = 4096
      size = 10
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_web2.id
    security_group_ids = [yandex_vpc_security_group.main_group.id]

  }

  metadata = {
    user-data = "${file("/home/vyach/sys-diplom/terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "elastic" {
  name = "elastic"
  hostname = "elastic-vm"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 4
  }

#  scheduling_policy {
#    preemptible = true
#  }

  boot_disk {
    initialize_params {
      image_id = "fd89dg1rq7uqslc6eigm"
      block_size = 4096
      size = 10
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_elk.id
    security_group_ids = [yandex_vpc_security_group.main_group.id]

  }

  metadata = {
    user-data = "${file("/home/vyach/sys-diplom/terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  hostname = "kibana-vm"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 4
  }

#  scheduling_policy {
#    preemptible = true
#  }

  boot_disk {
    initialize_params {
      image_id = "fd89dg1rq7uqslc6eigm"
      block_size = 4096
      size = 10
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_public.id
    security_group_ids = [yandex_vpc_security_group.main_group.id, yandex_vpc_security_group.kibana.id]
    nat = true
  }

  metadata = {
    user-data = "${file("/home/vyach/sys-diplom/terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  hostname = "zabbix-vm"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 4
  }

#  scheduling_policy {
#    preemptible = true
#  }

  boot_disk {
    initialize_params {
      image_id = "fd87j6d92jlrbjqbl32q"
      block_size = 4096
      size = 10
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_public.id
    security_group_ids = [yandex_vpc_security_group.main_group.id, yandex_vpc_security_group.zabbix.id]
    nat = true
  }

  metadata = {
    user-data = "${file("/home/vyach/sys-diplom/terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  hostname = "bastion-vm"
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 4
  }

#  scheduling_policy {
#    preemptible = true
#  }

  boot_disk {
    initialize_params {
      image_id = "fd89dg1rq7uqslc6eigm"
      block_size = 4096
      size = 10
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_public.id
    security_group_ids = [yandex_vpc_security_group.main_group.id, yandex_vpc_security_group.bastion.id]
    nat = true
  }

  metadata = {
    user-data = "${file("/home/vyach/sys-diplom/terraform/meta.txt")}"
  }
}