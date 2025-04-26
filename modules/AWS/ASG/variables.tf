variable "desired_capacity" {
  type = number
}
variable "max_size" {
  type = number
}
variable "min_size" {
  type = number
}
variable "vpc_zone_identifier" {
  type = list(string)
}
variable "launch_template_id" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "target_group_arns" {
  type = list(string)
}
