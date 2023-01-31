variable "image" {
  default = "rockylinux-9-x64"
}

variable "mastodon_init" {
  default = "./applications/mastodon/mastodon.tftpl"
}

variable pub_key {}

variable do_ssh_key {}

variable vpc_id {}

variable region {}

variable mastodon_size {}

variable db_size {}

variable mastodon_tag {}
