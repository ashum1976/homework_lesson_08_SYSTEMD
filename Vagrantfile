# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
            #config.vm.box = "ashum1976/centos7_kernel_5.10"
             config.vm.box = "centos/7"

             
            config.vm.provider "virtualbox" do |v|
                v.memory = 256
                v.cpus = 1
            end

            config.vm.define "systemd" do |std|
                #nfss.vm.synced_folder "./sync_data_server", "/home/vagrant/mnt"
                std.vm.hostname = "sstmd"
#                std.vm.provision "shell", path: "nfss_script.sh"
            end

end
