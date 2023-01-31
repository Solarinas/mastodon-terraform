terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

locals {
  # Setup CDN origin
  dev_cdn_domain= "${terraform.workspace == "dev" ? digitalocean_spaces_bucket.mastodon_s3_staging[0].bucket_domain_name : ""}"
  staging_cdn_domain = "${terraform.workspace == "staging" ? digitalocean_spaces_bucket.mastodon_s3_staging[0].bucket_domain_name : ""}"
  prod_cdn_domain = "${terraform.workspace == "prod" ? digitalocean_spaces_bucket.mastodon_s3_prod[0].bucket_domain_name : ""}"
  cdn_domain = "${coalesce(local.dev_cdn_domain,local.staging_cdn_domain,local.prod_cdn_domain)}"

}

# Create production s3 storage
resource "digitalocean_spaces_bucket" "mastodon_s3_prod" {
  count = "${terraform.workspace == "prod" ? 1 : 0}"
  name = "posthat-mastodon-cdn-${terraform.workspace}"
  region = var.region

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET", "POST", "DELETE", "HEAD"]
    allowed_origins = ["https://posthat.ca"]
    max_age_seconds = 3000
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create staging/dev s3 storage
resource "digitalocean_spaces_bucket" "mastodon_s3_staging" {
  count = "${terraform.workspace == "staging" || terraform.workspace == "dev" ? 1 : 0}"
  name = "posthat-mastodon-cdn-${terraform.workspace}"
  region = var.region
  acl = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET", "POST", "DELETE", "HEAD"]
    allowed_origins = ["https://${terraform.workspace}.posthat.ca"]
    max_age_seconds = 3000
  }

  force_destroy = true

  lifecycle {
    create_before_destroy = true
  }
}

# TODO: Custom domains will only work on the cdn resource if the DNS and SSL is managed by digitalocean. This will require a large rewrite by removing cloudflare and relying on DigitalOcean to manage those for us
resource "digitalocean_cdn" "mastodon_cdn" {
  origin = local.cdn_domain
}
