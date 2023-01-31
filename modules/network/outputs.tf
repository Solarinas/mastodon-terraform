output "vpc_id" {
  value = digitalocean_vpc.posthat_vpc.id
}

output "mastodon_tag" {
  value = digitalocean_tag.mastodon_tag.name
}
