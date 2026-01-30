terraform {
  backend "s3" {
    endpoint                    = "https://storage.yandexcloud.net"
    bucket                      = "tfstate-diploma-b1gmpjl1miqbc1m6f50k"
    region                      = "ru-central1"
    key                         = "network/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
