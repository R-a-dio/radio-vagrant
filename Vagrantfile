Vagrant.configure("2") do |config|
  config.vm.box = "radio"
  config.vm.box_url = "https://static.r-a-d.io/files/debian-7.2.0.box"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: "192.168.56.100"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "768"]
  end

  config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=775", "fmode=664"], :owner => "vagrant", :group => "www-data"

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
