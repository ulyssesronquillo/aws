provider "google" {
  project = "airy-totality-151318"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "meta" {
  name         = "meta"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-8"
    }
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}
