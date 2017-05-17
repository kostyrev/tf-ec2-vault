//-------------------------------------------------------------------
// Vault settings
//-------------------------------------------------------------------
variable "name" {
  description = "The cluster name, e.g cdn"
  type        = "string"
}

//-------------------------------------------------------------------
// AWS settings
//-------------------------------------------------------------------

variable "ami" {
  default     = "ami-7eb2a716"
  description = "AMI for Vault instances"
}

variable "elb-health-check" {
  default     = "HTTP:8200/v1/sys/health"
  description = "Health check for Vault servers"
}

variable "instance_type" {
  default     = "m3.medium"
  description = "Instance type for Vault instances"
}

variable "instance_profile" {
  description = "The instance profile to use"
  type        = "string"
}

variable "nodes" {
  default     = "3"
  description = "number of Vault instances"
}

variable "subnets" {
  description = "list of subnets to launch Vault within"
}

variable "vpc-id" {
  description = "VPC ID"
}

variable "datacenter" {
  description = "The datacenter in which the agent is running"
  default     = "dc1"
}

variable "ec2_tag_key" {
  description = "The Amazon EC2 instance tag key to filter on"
  default     = "consul_join"
}

variable "ec2_tag_value" {
  description = "The Amazon EC2 instance tag value to filter on"
  default     = "consul-cluster"
}

variable "bootstrap_expect" {
  description = "The number of expected servers in the datacenter"
  default     = "3"
}
