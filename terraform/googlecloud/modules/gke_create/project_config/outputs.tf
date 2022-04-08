output "budget_name" {
  description = "Resource name of the budget. Values are of the form `billingAccounts/{billingAccountId}/budgets/{budgetId}.`"
  value       = length(google_billing_budget.budget) > 0 ? google_billing_budget.budget[0].name : ""
}
output "quota_overrides" {
  description = "The server-generated names of the quota override."
  value       = google_service_usage_consumer_quota_override.override
}