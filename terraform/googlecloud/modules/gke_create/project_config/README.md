## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.16.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.16.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_service_usage_consumer_quota_override.override](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_service_usage_consumer_quota_override) | resource |
| [google_billing_budget.budget](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_budget) | resource |
| [google_monitoring_notification_channel.email](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel) | resource |
| [google_monitoring_notification_channel.sms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel) | resource |
| [google_pubsub_topic.budget](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_monitoring_notification_channel.email](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/monitoring_notification_channel) | data source |
| [google_monitoring_notification_channel.sms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/monitoring_notification_channel) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_pubsub_topic.budget](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/pubsub_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_pubsub_topic"></a> [alert\_pubsub\_topic](#input\_alert\_pubsub\_topic) | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| <a name="input_alert_spend_basis"></a> [alert\_spend\_basis](#input\_alert\_spend\_basis) | The type of basis used to determine if spend has passed the threshold | `string` | `"CURRENT_SPEND"` | no |
| <a name="input_alert_spent_percents"></a> [alert\_spent\_percents](#input\_alert\_spent\_percents) | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.7,<br>  1<br>]</pre> | no |
| <a name="input_amount"></a> [amount](#input\_amount) | The amount to use as the budget | `number` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | ID of the billing account to set a budget on | `string` | n/a | yes |
| <a name="input_consumer_quotas"></a> [consumer\_quotas](#input\_consumer\_quotas) | The quotas configuration you want to override for the project. | <pre>list(object({<br>    service = string,<br>    metric  = string,<br>    limit   = string,<br>    value   = string,<br>  }))</pre> | n/a | yes |
| <a name="input_create_budget"></a> [create\_budget](#input\_create\_budget) | If the budget should be created | `bool` | `true` | no |
| <a name="input_credit_types_treatment"></a> [credit\_types\_treatment](#input\_credit\_types\_treatment) | Specifies how credits should be treated when determining spend for threshold calculations | `string` | `"INCLUDE_ALL_CREDITS"` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The display name of the budget. If not set defaults to `Budget For <projects[0]|All Projects>` | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget. | `map(string)` | `{}` | no |
| <a name="input_notification_channels_email"></a> [notification\_channels\_email](#input\_notification\_channels\_email) | email to be notified of budget laith@email.com | `string` | n/a | yes |
| <a name="input_notification_channels_sms"></a> [notification\_channels\_sms](#input\_notification\_channels\_sms) | phone number to be notified +13333333333 | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `string` | n/a | yes |
| <a name="input_projects"></a> [projects](#input\_projects) | The project ids to include in this budget. If empty budget will include all projects | `list(string)` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/ | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_name"></a> [budget\_name](#output\_budget\_name) | Resource name of the budget. Values are of the form `billingAccounts/{billingAccountId}/budgets/{budgetId}.` |
| <a name="output_quota_overrides"></a> [quota\_overrides](#output\_quota\_overrides) | The server-generated names of the quota override. |
