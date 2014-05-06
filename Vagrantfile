# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "wheezy"
  config.vm.box_url = "https://s3-eu-west-1.amazonaws.com/ffuenf-vagrant-boxes/debian/debian-7.2.0-amd64.box"

  config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "768"]
  end

  config.vm.provision :chef_solo do |chef|
      # chef.log_level = :debug

      chef.add_recipe "nginx::repo"
      chef.add_recipe "nginx"
      chef.add_recipe "web"

      chef.json = {
        "nginx" => {
          "default_site_enabled" => false
        },
        "web" => {
            "repo"        => "https://github.com/R-a-dio/site",
            "repo_branch" => "develop",
            "repo_name"   => "radio_site",
        }
      }
  end
end
