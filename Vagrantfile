Vagrant::Config.run do |config|
  config.vm.box = "lucid32"
  config.vm.host_name = "socialteeth-vagrant"
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port 8200, 8200
end
