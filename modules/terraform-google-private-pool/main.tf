resource "google_compute_network" "default" {
  project = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_global_address" "default" {
  project = var.project_id

  name          = var.global_address_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.global_address_prefix_length
  address       = var.global_address
  network       = google_compute_network.default.id
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default.name]
}

resource "google_cloudbuild_worker_pool" "pool" {
  project = var.project_id

  name          = var.pool_name
  location      = var.pool_location

  worker_config {
    disk_size_gb = var.disk_size_gb
    machine_type = var.machine_type
    no_external_ip = var.no_external_ip
  }

  network_config {
    peered_network = google_compute_network.default.id
  }
}