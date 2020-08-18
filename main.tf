// *****************  Test2 ******************************************************

// Configure the Google Clou1d provider
provider "google" {
  credentials = file("/home/rodney/Downloads/flask-app-cf16973fe8c9.json")
  project = "flask-app-286314"
  region = "us-west1"
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "default" {
  name = "flask-vm-${random_id.instance_id.hex}"  #naming per google's best practices
  machine_type = "f1-micro" #micros are free
  zone = "us-west1-a" #whatever region 

  boot_disk{
    initialize_params {
      #image = "debian-cloud/debian-9"
      #image =  "debian-10-buster-v20200805"
      #image = "ubuntu-minimal-2004-focal-v20200729"
      image = "centos-7-v20200403"
    }
  }

  #set up a basic install
  #metadata_startup_script = "yum check-update; yum update -y; yum install -y yum-utils; yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo; yum install -y docker-ce docker-ce-cli containerd.io; systemctl start docker"
  metadata_startup_script = <<-EOT
    "yum check-update; yum update -y; yum install -y yum-utils;"
    "yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo;"
    "yum install -y docker-ce docker-ce-cli containerd.io; systemctl start docker"
  EOT
  network_interface {
    network = "default"
  
    access_config {
      //Include this section to give the VM an external ip address
    }
  }
  
  metadata = {
    ssh-keys = "rodney:${file("~/.ssh/id_rsa.pub")}"
  }

}

  output "ip" {
    value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
  }