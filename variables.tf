# Load from Pass
variable "do_token" {
  sensitive = true
}

variable "cf_token" {
  sensitive = true
}

variable "zone_id" {
  sensitive = true
}

variable "access_key" {
  sensitive = true
}

variable "secret_key" {
  sensitive = true
}

# SSH keys
variable "pub_key" {
  default = "/var/home/solarinas/.ssh/solarinas.pub"
}

variable "do_ssh_key" {
  default = "solarinas"
}

# Load from ENV
variable "region" {}

variable "ip_range"  {}

variable mastodon_size {}

variable db_size {}
