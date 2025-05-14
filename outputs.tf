##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

output "macie_account_id" {
  value = aws_macie2_account.this.id
}

output "macie_service_role_arn" {
  value = aws_macie2_account.this.service_role
}

output "macie_finding_filters" {
  value = {
    for k, v in aws_macie2_findings_filter.finding_filter : k => {
      id  = v.id
      arn = v.arn
    }
  }
}