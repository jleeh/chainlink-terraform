variable "region" {
  default = "us-east-2"
}

variable "name" {
  default = "tf"
}

variable "allowed_cidr" {
  type = "list"

  default = [
    "0.0.0.0/0",
  ]
}

variable "image_tag" {
  default = "0.5.2"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "log_retention" {
  default = 7
}

variable "login_email" {
  default = "admin@chain.link"
}

variable "env_vars" {
  type = "list"

  default = [
    ["ETH_CHAIN_ID", "3"],
    ["ETH_URL", "wss://ropsten-rpc.linkpool.io/ws"],
    ["LINK_CONTRACT_ADDRESS", "0x514910771af9ca656af840dff83e8264ecf986ca"],
  ]
}