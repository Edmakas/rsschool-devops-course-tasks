variable "domain_name" {
  description = "The domain name for the hosted zone (e.g., tuselis.lt)"
  type        = string
}

variable "jenkins_ip_address" {
  description = "The public IP address of the Jenkins server"
  type        = string
} 