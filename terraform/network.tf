# yandex_vpc_network

resource "yandex_vpc_network" "network_sys" {
  name = "network-sys"
}

# yandex_vpc_subnet

resource "yandex_vpc_subnet" "subnet_web1" {
  name           = "subnet-web1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_sys.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_subnet" "subnet_web2" {
  name           = "subnet-web2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network_sys.id
  v4_cidr_blocks = ["192.168.11.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_subnet" "subnet_elk" {
  name           = "subnet-elk"
  v4_cidr_blocks = ["192.168.12.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_sys.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_subnet" "subnet_public" {
  name           = "subnet-public"
  v4_cidr_blocks = ["192.168.13.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_sys.id
}

#NAT-шлюз

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name = "route-table"
  network_id = yandex_vpc_network.network_sys.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# 1 target_group

resource "yandex_alb_target_group" "web" {
  name = "web"
  target {
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
    subnet_id = yandex_vpc_subnet.subnet_web1.id
  }
  
  target {
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
    subnet_id = yandex_vpc_subnet.subnet_web2.id
  }
}

# 2 backend_group

resource "yandex_alb_backend_group" "backend_group" {
  name = "backend-group"

  http_backend {
    name = "backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    load_balancing_config {
      panic_threshold = 90
    }

    healthcheck {
      timeout = "15s"
      interval = "2s"
      healthy_threshold = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# 3 HTTP-роутер

resource "yandex_alb_http_router" "http_router" {
  name = "http-router"
}

resource "yandex_alb_virtual_host" "virtual_router_host" {
  name           = "virtual-router-host"
  http_router_id = yandex_alb_http_router.http_router.id
  route {
    name = "root-path"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend_group.id
        timeout          = "3s"
      }
    }
  }
}

# 4 балансировщик

resource "yandex_alb_load_balancer" "load_balancer" {
  name               = "load-balancer"
  network_id         = yandex_vpc_network.network_sys.id
  security_group_ids = [yandex_vpc_security_group.lb_group.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet_public.id
    }
  }

  listener {
    name = "listener"

    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.http_router.id
      }
    }
  }
}

# security_group

resource "yandex_vpc_security_group" "main_group" {
  name       = "main-group"
  network_id = yandex_vpc_network.network_sys.id

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = [
        "192.168.10.0/24", 
        "192.168.11.0/24", 
        "192.168.12.0/24", 
        "192.168.13.0/24"
        ]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "lb_group" {
  name       = "lb-group"
  network_id = yandex_vpc_network.network_sys.id

  ingress {
    protocol          = "ANY"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion"
  network_id = yandex_vpc_network.network_sys.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix" {
  name       = "zabbix"
  network_id = yandex_vpc_network.network_sys.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10050
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "kibana"
  network_id = yandex_vpc_network.network_sys.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}