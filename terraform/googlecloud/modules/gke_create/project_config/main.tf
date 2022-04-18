locals {
  project_name     = length(var.projects) == 0 ? "All Projects" : var.projects[0]
  display_name     = var.display_name == null ? "Budget For ${local.project_name}" : var.display_name
  all_updates_rule = var.alert_pubsub_topic == null && length(var.monitoring_notification_channels) == 0 ? [] : ["1"]
  consumer_quotas  = { for index, quota in var.consumer_quotas : "${quota.service}-${quota.metric}" => quota }

  projects = length(var.projects) == 0 ? null : [
    for project in data.google_project.project :
    "projects/${project.number}"
  ]
  services = var.services == null ? null : [
    for id in var.services :
    "services/${id}"
  ]
}
resource "google_pubsub_topic" "budget" {
  name    = "budget-topic-${var.project_name}"
  project = var.project_id
}
resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "Email Channel"
  type         = "email"
  labels = {
    email_address = "${var.notification_channels_email}"
  }
}
resource "google_monitoring_notification_channel" "sms" {
  project      = var.project_id
  display_name = "SMS Channel"
  type         = "sms"
  labels = {
    number = "${var.notification_channels_sms}"
  }
}
data "google_pubsub_topic" "budget" {
  name       = "budget-topic-${var.project_name}"
  depends_on = [google_pubsub_topic.budget]
}
# data "google_monitoring_notification_channel" "sms" {
#   display_name = "SMS Channel"
#   depends_on   = [google_monitoring_notification_channel.sms]
# }
# data "google_monitoring_notification_channel" "email" {
#   display_name = "Email Channel"
#   depends_on   = [google_monitoring_notification_channel.email]
# }
data "google_project" "project" {
  count      = length(var.projects)
  project_id = element(var.projects, count.index)
  depends_on = [var.projects]
}
resource "google_billing_budget" "budget" {
  count = var.create_budget ? 1 : 0
  billing_account = var.billing_account
  display_name    = local.display_name

  budget_filter {
    projects               = local.projects
    credit_types_treatment = var.credit_types_treatment
    services               = local.services
    labels                 = var.labels
  }

  amount {
    specified_amount {
      units = tostring(var.amount)
    }
  }

  dynamic "threshold_rules" {
    for_each = var.alert_spent_percents
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = var.alert_spend_basis
    }
  }

  dynamic "all_updates_rule" {
    for_each = local.all_updates_rule
    content {
      pubsub_topic                     = var.alert_pubsub_topic == null ? data.google_pubsub_topic.budget.id : var.alert_pubsub_topic
      monitoring_notification_channels = var.monitoring_notification_channels == null ? [google_monitoring_notification_channel.email.name, google_monitoring_notification_channel.sms.name] : var.monitoring_notification_channels
    }
  }
}
