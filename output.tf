output "ou-vrbz-sb5wzrsg_accounts" {
    value = local.ou-vrbz-sb5wzrsg_accounts
}

output "ou-vrbz-ugxa0808_accounts" {
    value = local.no-ou_accounts
}

output "no-ou_accounts" {
    value = local.no-ou_accounts
}

output "unclassified_accounts" {
    value = lacework_resource_group_aws.AllOtherUnclassifiedAccounts.accounts
}

output "bu-1" {
    value = lacework_resource_group_aws.business_unit_1.accounts
}

output "bu-2" {
    value = lacework_resource_group_aws.business_unit_2.accounts
}

output "all_account_ids" {
  value = data.aws_organizations_organization.org1.accounts[*].id
}