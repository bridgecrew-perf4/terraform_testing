terraform {
  required_providers { //Aqui é só para dizer o que vai ser usado!!!
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 1.20"
    }
  }
  required_version = ">= 0.13"
}

provider "vsphere" {
  user           = ""
  password       = ""
  vsphere_server = ""
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "vCenter"
  datacenter_id = data.vsphere_datacenter.dc.id
}

 data "vsphere_compute_cluster" "cluster" {
   name          = "vCluster2"
   datacenter_id = data.vsphere_datacenter.dc.id
 }

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 1024
  guest_id = "ubuntu64Guest"
  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1
  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = "ISOS/hirsute-live-server-amd64.iso"
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 20
  }
}