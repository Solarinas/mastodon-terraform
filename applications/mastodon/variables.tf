variable "image" {
  default = "rockylinux-9-x64"
}

variable "mastodon_init" {
  default = "./applications/mastodon/mastodon.tftpl"
}

variable ssh_pub_key {}

variable ssh_prvt_key {}

variable do_ssh_key {}

variable vpc_id {}

variable region {}

variable mastodon_size {}

variable db_size {}

variable mastodon_tag {}
