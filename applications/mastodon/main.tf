terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

locals {
  mastodon_droplet_name = "posthat-mastodon-${terraform.workspace}"

  # Setup Database volume variable
  dev_volume = "${terraform.workspace == "dev" ? digitalocean_volume.mastodon_db_dev[0].id : ""}"
  staging_volume = "${terraform.workspace == "staging" ? digitalocean_volume.mastodon_db_staging[0].id : "" }"
  prod_volume = "${terraform.workspace == "prod" ? digitalocean_volume.mastodon_db_prod[0].id : "" }"
  volume = "${coalesce(local.dev_volume,local.staging_volume,local.prod_volume)}"

  date = timestamp()
}

# import ssh key from digitalocean
data "digitalocean_ssh_key" "admin_key" {
  name = var.do_ssh_key
}

# Production database volume
resource "digitalocean_volume" "mastodon_db_prod" {
  count = "${terraform.workspace == "prod" ? 1 : 0}"
  name = "posthat-mastodon-db-${terraform.workspace}"
  region = var.region
  size = var.db_size

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_volume" "mastodon_db_staging" {
  count = "${terraform.workspace == "staging" ? 1 : 0}"
  name = "posthat-mastodon-db-${terraform.workspace}"
  region = var.region
  size = var.db_size

  lifecycle {
    create_before_destroy = true
  }
}

# Dev database volume
resource "digitalocean_volume" "mastodon_db_dev" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  name = "posthat-mastodon-db-${terraform.workspace}"
  region = var.region
  size = var.db_size

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_droplet" "mastodon" {
  image = var.image
  name = local.mastodon_droplet_name
  region = var.region
  size = var.mastodon_size
  vpc_uuid = var.vpc_id

  ssh_keys = [
    data.digitalocean_ssh_key.admin_key.id
  ]

  user_data = templatefile(var.mastodon_init,
    {
      pub_key = file(var.ssh_pub_key)
    })

  volume_ids = [
    local.volume
  ]

  tags = [
    var.mastodon_tag,
  ]

  provisioner "remote-exec" {
    inline = ["sudo dnf install -y python"]

    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "solar"
      private_key = file(var.ssh_prvt_key)
    }
  }

  provisioner "local-exec" {
    environment = {
      ANSIBLE_CONFIG = "${path.root}/playbooks/mastodon-playbook/ansible.cfg"
    }
    command = "ansible-playbook -i ${digitalocean_droplet.mastodon.ipv4_address}, -e ansible_ssh_user=solar playbooks/mastodon-playbook/setup.yml"
  }
}
