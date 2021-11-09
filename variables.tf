/*
________ALERT RULES________
  name             = "Compliance to Group 1 Jira"
  description      = "Compliance to Group 1 Jira"
  channels         = [lacework_alert_channel_jira.customer_jira1.id]
  severities       = ["Critical", "High"]
  event_categories = ["Compliance"]
  resource_groups  = ["group_1_jira"]
*/
variable "bu_count"{
  type = number
  default = 2
}

variable "list_config" {
  type = any
  default = [
    {
      compliance_alert_channel = "jira_channel_1"
      anomaly_alert_channel = "servicenow_channel_1"
      bu_resource_group_name = "bu_1"
      resource_group_accounts = [092184108996, 081556044659, 865876543607]
    }, 
    {
      compliance_alert_channel = "jira_channel_2"
      anomaly_alert_channel = "servicenow_channel_1"
      bu_resource_group_name = "bu_2"
      resource_group_accounts = [912786606823]
    }
  ]
}

variable "organization_map" {
  type = map
  default = {
    root = {

      ou-vrbz-sb5wzrsg = [
        092184108996, 
        081556044659, 
        865876543607
      ]

      ou-vrbz-ugxa0808 = [
        912786606823
      ]

      no-ou = [
        791529083252,
        019659989168,
        004507715063,
        310935373214,
        373407869938,
        698827576654
      ]
    }
  }
}