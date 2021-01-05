variable "region" {
  default = "eu-west-1"
}

variable "amis" {
  type = map(any)
  default = {
    "eu-west-1" = "ami-0016b8f1b5f1c4a8d"
  }
}

variable "curr_profile" {
  default = "default"
}
