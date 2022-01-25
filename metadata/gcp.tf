provider "google" {
  project = var.project
  zone    = "us-central1-c"
}

variable "project" { type = string }

resource "google_compute_instance" "meta" {
  name         = "meta"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-8"
    }
  }

  tags = ["http-server"]

  metadata_startup_script = <<EOF
#!/bin/bash
hostnamectl set-hostname test
dnf install nginx -y
systemctl start nginx
systemctl enable nginx
sleep 10
echo "web1" > /usr/share/nginx/html/index.html
EOF
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
