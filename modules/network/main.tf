terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

resource "digitalocean_vpc" "posthat_vpc" {
  name = "posthat-vpc-${terraform.workspace}"
  region = var.region
  ip_range = var.ip_range
}

resource "digitalocean_tag" "mastodon_tag" {
  name = "posthat-mastodon-${terraform.workspace}"
}

resource "digitalocean_firewall" "mastodon_firewall" {
  name = "posthat-mastodon-firewall-${terraform.workspace}"

  depends_on = [
    digitalocean_tag.mastodon_tag
  ]

  tags = [ digitalocean_tag.mastodon_tag.name ]

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Only allowed cloudflare connections to web server
  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22"
    ]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22"
    ]
  }
    # allow outbound connections
  outbound_rule {
    protocol = "tcp"
    port_range = "1-65535"
    destination_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  outbound_rule {
    protocol = "udp"
    port_range = "1-65535"
    destination_addresses = [ "0.0.0.0/0", "::/0" ]
  }
}
