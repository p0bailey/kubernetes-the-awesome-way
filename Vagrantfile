# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box = "p0bailey/k8"

    config.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 2
      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    end

    config.vm.define "master" do |node|
      node.vm.hostname = "master"
      node.vm.network :private_network, ip: "192.168.33.10"
      node.vm.provision :shell, inline: "sed 's/127\.0\.1\.1.*master.*/192\.168\.33\.10 master/' -i /etc/hosts"
    end

    config.vm.define "node1" do |node|
      node.vm.hostname = "node1"
      node.vm.network :private_network, ip: "192.168.33.20"
      node.vm.provision :shell, inline: "sed 's/127\.0\.1\.1.*node1.*/192\.168\.33\.20 node1/' -i /etc/hosts"
    end

    # config.vm.define "node2" do |node|
    #   node.vm.hostname = "node2"
    #   node.vm.network :private_network, ip: "192.168.33.30"
    #   node.vm.provision :shell, inline: "sed 's/127\.0\.1\.1.*node2.*/192\.168\.33\.30 node2/' -i /etc/hosts"
    # end

    # config.vm.define "node3" do |node|
    #   node.vm.hostname = "node3"
    #   node.vm.network :private_network, ip: "192.168.33.40"
    #   node.vm.provision :shell, inline: "sed 's/127\.0\.1\.1.*node3.*/192\.168\.33\.40 node3/' -i /etc/hosts"
    # end

end
