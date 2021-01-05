terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.18.0"
    }
  }
}

variable "ibmcloud_api_key" {

}

# Configure the IBM Provider
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "eu-de"
  generation       = 1
}

resource "ibm_is_vpc" "testacc_vpc" {
  name = "test-vpc"
}
