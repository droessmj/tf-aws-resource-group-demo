# Provider setup
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.62.0"
    }
    lacework = {
      source = "lacework/lacework"
      version = ">= 0.12.0"
    }
  }
}

provider "aws" {
  # any basic AWS configuration -- will require ability to read 
  # the organization if any org data sources are in use
  region = "us-east-2"
  #profile = "default-personal"
}

provider "lacework" {
  # Configuration options
}

#####################################################################
# Data Source Configuration -- Mapping AWS upstreams to Local sources
# -------------------------------------------------------------------
# This can probably be done as a loop over variables if you modify the 
# variable input to be an array of maps, but that syntax is pretty 
# convoluted and I'm trying to avoid confusion where possible
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization
#####################################################################

# use the AWS organization data source...
#### https://github.com/hashicorp/terraform-provider-aws/pull/18589
# ^^^ stalled...maybe use `aws organizations list-children` to walk structure
# and build a map of OU -> accounts, and then feed that map in as variables?
data "aws_organizations_organization" "org1" {}

locals {
  ou-vrbz-sb5wzrsg_accounts = var.organization_map.root.ou-vrbz-sb5wzrsg
  ou-vrbz-ugxa0808_accounts = var.organization_map.root.ou-vrbz-ugxa0808
  no-ou_accounts = var.organization_map.root.no-ou

}

#####################################################################
# Resource Group Configuration
#--------------------------------------------------------------------
# Map Resource Groups to Alert Channels and Rules
# https://registry.terraform.io/providers/lacework/lacework/latest/docs/resources/resource_group_gcp
#####################################################################
resource "lacework_resource_group_aws" "lacework_aws_rg" {
  count        = var.bu_count
  name         = "bu_${count.index}"
  description  = var.list_config[count.index].bu_resource_group_name
  accounts     = var.list_config[count.index].resource_group_accounts 
}

resource "lacework_resource_group_aws" "all_aws_projects" {
  name         = "AWS Resource Group"
  description  = "All AWS Projects"
  accounts     = ["*"]
}

resource "lacework_resource_group_aws" "business_unit_1" {
  name         = "business_unit_1 AWS Accounts"
  description  = "business_unit_1 AWS Accounts"
  accounts     = local.ou-vrbz-sb5wzrsg_accounts
}

resource "lacework_resource_group_aws" "business_unit_2" {
  name         = "business_unit_2 AWS Accounts"
  description  = "business_unit_2 AWS Accounts"
  accounts     = local.ou-vrbz-ugxa0808_accounts
}

# Special resource group which is built of all discovered projects which 
# are not otherwise mapped per the data sources above. Works by taking a special
# data source of ALL projects, and then subtracts out all already classified
# projects - leaving a set of unclassified projects. Syntax is currently 
# a bit messy. Will update if a cleaner way is discovered.

# Logic:
# (All Accounts) - bu1 - bu2 - ... n == All Unclassified Projects
resource "lacework_resource_group_aws" "AllOtherUnclassifiedAccounts" {
  count        = try(length(data.aws_organizations_organization.org1.accounts),0)
  name         = "AWS - All Unclassified Accounts"
  description  = "All accounts not otherwise specified"
  # there has to be a cleaner way to do this....best I can do for the moment
  accounts     = setsubtract(data.aws_organizations_organization.org1.accounts[*].id, local.no-ou_accounts) 
}

#####################################################################
# Defined Alert Channels 
#--------------------------------------------------------------------
# More info on available Alert Channels can be found at this link
# https://registry.terraform.io/providers/lacework/lacework/latest/docs
#####################################################################

#https://registry.terraform.io/providers/lacework/lacework/latest/docs/resources/alert_channel_service_now

/*
resource "lacework_alert_channel_service_now" "customer_servicenow" {
  name         = "Service Now Alerts"
  instance_url = "snow-lacework.com"
  username     = "snow-user"
  password     = "snow-pass"
}

resource "lacework_alert_channel_jira_server" "customer_jira1" {
  name        = "jira"
  jira_url    = "jira.customer.com"
  issue_type  = "Bug"
  project_key = "SEC"
  username    = "lacework-for-jira"
  password    = "TBD..source from outside this file!"
}

resource "lacework_alert_channel_jira_server" "customer_jira2" {
  name        = "jira"
  jira_url    = "jira.customer.com"
  issue_type  = "Bug"
  project_key = "SEC"
  username    = "lacework-for-jira"
  password    = "TBD..source from outside this file!"
}
*/

resource "lacework_alert_channel_email" "notify_someone_over_email" {
  name       = "Notify Someone Over Email"
  recipients = [
    "michael.droessler@lacework.net"
  ]
}

#####################################################################
# Defined Alert Rules
#--------------------------------------------------------------------
# Map a set of events (Compliance, Agent Anomaly, etc) for a given 
# collection of sources (Resource Group) to a target Alert Channel
# https://registry.terraform.io/providers/lacework/lacework/latest/docs/resources/alert_rule
#####################################################################

/*
The following arguments are supported:

name - (Required) The alert rule name.
channels - (Required) The list of alert channels for the rule to use.
severities - (Required) The list of the severities that the rule will apply. Valid severities include: Critical, High, Medium, Low and Info.
description - (Optional) The description of the alert rule.
event_categories - (Optional) The list of event categories the rule will apply to. Valid categories include: Compliance, App, Cloud,File, Machine, User and Platform.
resource_groups - (Optional) The list of resource groups the rule will apply to.
enabled - (Optional) The state of the external integration. Defaults to true.
*/

resource "lacework_alert_rule" "route_behavior_crit_high_servicenow" {
  name             = "Cloud Critical, High to ServiceNow"
  description      = "Cloud Critical, High to ServiceNow"
  channels         = [lacework_alert_channel_email.notify_someone_over_email.id]
  severities       = ["Critical", "High"]
  event_categories = ["Cloud"]
  resource_groups  = [lacework_resource_group_aws.all_aws_projects.id]
}

resource "lacework_alert_rule" "route_compliance_jira1" {
  name             = "Compliance to Group 1 Jira"
  description      = "Compliance to Group 1 Jira"
  channels         = [lacework_alert_channel_email.notify_someone_over_email.id]
  severities       = ["Critical", "High"]
  event_categories = ["Compliance"]
  resource_groups  = [lacework_resource_group_aws.lacework_aws_rg[0].id]
}

resource "lacework_alert_rule" "route_compliance_jira2" {
  name             = "Compliance to Group 2 Jira"
  description      = "Compliance to Group 2 Jira"
  channels         = [lacework_alert_channel_email.notify_someone_over_email.id]
  severities       = ["Critical", "High"]
  event_categories = ["Compliance"]
  resource_groups  = [lacework_resource_group_aws.lacework_aws_rg[1].id]
}
