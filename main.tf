terraform {
  required_version = ">= 1.1.0"
}

variable "nb_nodes" {}
variable "password" {}

module "ovh" {
  source         = "./ovh"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "11.9.3"

  cluster_name = "bob"
  domain       = "calculquebec.cloud"
  image        = "Centos 7"
  sudoer_username = "alex"

  instances = {
    mgmt   = { type = "b2-7", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "b2-7", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "b2-7", tags = ["node"], count = var.nb_nodes }
  }

  volumes = {
    nfs = {
      home     = { size = 10 }
      project  = { size = 50 }
      scratch  = { size = 50 }
    }
  }
  public_keys = [file("~/.ssh/id_ed25519_23022022.pub")]

  nb_users     = 10
  # Shared password, randomly chosen if blank
  guest_passwd = var.password

}

output "accounts" {
  value = module.ovh.accounts
}

output "public_ip" {
  value = module.ovh.public_ip
}

## Uncomment to register your domain name with CloudFlare
# module "dns" {
#   source           = "./dns/cloudflare"
#   email            = "you@example.com"
#   name             = module.ovh.cluster_name
#   domain           = module.ovh.domain
#   public_instances = module.ovh.public_instances
#   ssh_private_key  = module.ovh.ssh_private_key
#   sudoer_username  = module.ovh.accounts.sudoer.username
# }

## Uncomment to register your domain name with Google Cloud
# module "dns" {
#   source           = "./dns/gcloud"
#   email            = "you@example.com"
#   project          = "your-project-id"
#   zone_name        = "you-zone-name"
#   name             = module.ovh.cluster_name
#   domain           = module.ovh.domain
#   public_instances = module.ovh.public_instances
#   ssh_private_key  = module.ovh.ssh_private_key
#   sudoer_username  = module.ovh.accounts.sudoer.username
# }

# output "hostnames" {
#   value = module.dns.hostnames
# }
