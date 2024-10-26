provider "google" {
  project = "gcp-learners-123"
  region  = "us-central1"
}
resource "google_compute_network" "vpc_network1"{
  name = "vpc1"
  auto_create_subnetworks = true
 }
resource "google_compute_network" "vpc_network2"{
  name = "vpc2"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "vpc2_custom_subnet" {
  name                    = "vpc2-custom-subnet"
  ip_cidr_range           = "10.9.0.0/16"
  region                  = "us-central1"
  network                 = google_compute_network.vpc_network2.name
}
resource "google_compute_instance" "vm-instance1"{
  name         = "vm1"
  machine_type = "e2-medium"
  zone         = "us-central1-a"   

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20221102"
    } 
  }
  network_interface { 
    network = google_compute_network.vpc_network1.name

    access_config {
      // Ephemeral IP
    }
  }
  }
resource "google_compute_instance" "vm-instance2"{
  name         = "vm2"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
        image = "debian-10-buster-v20221102"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.vpc2_custom_subnet.id
    access_config {
      // Ephemeral IP
    }
  }
  }
  resource "google_compute_firewall" "vpc1_firewall" {
  name    = "vpc1-firewall"
  network = google_compute_network.vpc_network1.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol      = "tcp"
    ports         = ["22"]

  }
  source_ranges = ["0.0.0.0/0"]
  }
  resource "google_compute_firewall" "vpc2_firewall" {
  name    = "vpc2-firewall"
  network = google_compute_network.vpc_network2.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol       = "tcp"
    ports          = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  }
  resource "google_compute_network_peering" "peering-vpc1-to-vpc2" {
  name         = "vpc1-to-vpc2"
  network      = google_compute_network.vpc_network1.id
  peer_network = google_compute_network.vpc_network2.id

  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_network_peering" "peering-vpc2-to-vpc1" {
  name         = "vpc2-to-vpc1"
  network      = google_compute_network.vpc_network2.id
  peer_network = google_compute_network.vpc_network1.id
}

