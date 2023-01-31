terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

# Mastodon domain
resource "cloudflare_record" "mastodon_domain" {
  zone_id = var.zone_id
  name = "${terraform.workspace}" == "prod" ? "www" : "${terraform.workspace}"
  value = var.mastodon_ipv4_pub
  type = "A"
  proxied = true
}
