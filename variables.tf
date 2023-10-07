variable "domain_name" {

}

variable "account" {

}

variable "bastion_authorized_keys" {
    default = ""
}

variable "bastion_enable" {
    default = false
}

variable "web_service_scale" {
    default = 2
}

variable "web_service_cpu" {
    default = 1024
}

variable "web_service_mem" {
    default = 2048
}

variable "mail_service_cpu" {
    default = 1024
}

variable "mail_service_mem" {
    default = 2048
}

variable "azs" {
    default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "subnet_number" {
    default = "10"
}

variable "docker_image_version" {
    default = "latest"
}

variable "docker_image_web" {
    default = "funnela/funnela-web"
}

variable "docker_image_mail_daemon" {
    default = "funnela/funnela-mail-daemon"
}

variable "mail_support_enabled" {
    default = true
}

variable "db_instance_type" {
    default = "db.t3.small"
}

variable "redis_instance_type" {
    default = "cache.t4g.micro"
}

variable "db_storage" {
    default = "10"
}

variable "db_max_storage" {
    default = "20"
}
