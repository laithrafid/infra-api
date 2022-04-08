variable "project_name" {
  type = string
}
variable "project_id" {
  type = string
}
variable "monitoring_notification_channels" {
  type = list(string)
  description = "list of already created monitoring notification channels"
  default = []
}
variable "notification_channels_sms" {
  description = "phone number to be notified +13333333333"
  type        = string
}
variable "notification_channels_email" {
  description = "email to be notified of budget laith@email.com"
  type        = string
}
variable "billing_account" {
  description = "ID of the billing account to set a budget on"
  type        = string
}

variable "projects" {
  description = "The project ids to include in this budget. If empty budget will include all projects"
  type        = list(string)
  default = []
}

variable "amount" {
  description = "The amount to use as the budget"
  type        = number
}

variable "create_budget" {
  description = "If the budget should be created"
  type        = bool
  default     = true
}

variable "display_name" {
  description = "The display name of the budget. If not set defaults to `Budget For <projects[0]|All Projects>` "
  type        = string
  default     = null
}

variable "credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations"
  type        = string
  default     = "INCLUDE_ALL_CREDITS"
}

variable "services" {
  description = "A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/"
  type        = list(string)
  default     = null
}

variable "alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded"
  type        = list(number)
  default     = [0.5, 0.7, 1.0]
}

variable "alert_spend_basis" {
  description = "The type of basis used to determine if spend has passed the threshold"
  type        = string
  default     = "CURRENT_SPEND"
}

variable "alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`"
  type        = string
  default     = null
}

variable "labels" {
  description = "A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget."
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.labels) <= 1
    error_message = "Only 0 or 1 labels may be supplied for the budget filter."
  }
}
variable "consumer_quotas" {
  description = "The quotas configuration you want to override for the project."
  type = list(object({
    service = string,
    metric  = string,
    limit   = string,
    value   = string,
  }))
}