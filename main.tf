terraform {
  # Store Terraform data remotely
  backend "s3" {
    skip_credentials_validation = true
    bucket = "posthat-mastodon-state"
    endpoint = "https://nyc3.digitaloceanspaces.com"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
  # import the required providers and their versions
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.25"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.33.1"
    }
  }
}

# load API tokens
provider "digitalocean" {
  token = var.do_token

  spaces_access_id = var.access_key
  spaces_secret_key =  var.secret_key
}

provider "cloudflare" {
  api_token = var.cf_token
}

# Create a VPC for the enviornment
module "network" {
  source = "./modules/network"

  # Enviornment variables
  ip_range = var.ip_range
  region = var.region

}

# Create a CDN to store user files
module "cdn" {
  source = "./applications/cdn"

  region = var.region
}

# Create the mastodon instance
module "mastodon" {
  source = "./applications/mastodon"

  ssh_pub_key = var.ssh_pub_key
  ssh_prvt_key = var.ssh_prvt_key
  do_ssh_key = var.do_ssh_key

  vpc_id = module.network.vpc_id
  mastodon_tag = module.network.mastodon_tag

  region = var.region
  mastodon_size = var.mastodon_size
  db_size = var.db_size
}

# route cloudflare to mastodon
module "dns" {
  source = "./modules/dns"

  zone_id = var.zone_id

  mastodon_ipv4_pub = module.mastodon.mastodon_ipv4_pub
}
