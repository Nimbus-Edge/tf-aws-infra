variable "name" {
  type = string
}

variable "comparison_operator" {
  type = string
}

variable "metric_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "period" {
  type = number
}

variable "threshold" {
  type = number
}

variable "statistic" {
  type = string
}

variable "alarm_actions" {
  type = list(string)
}

variable "autoscaling_group_name" {
  type = string
}
