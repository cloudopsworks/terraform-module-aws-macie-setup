##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "aws_macie2_account" "this" {
  status                       = try(var.settings.enabled, true) ? "ENABLED" : "DISABLED"
  finding_publishing_frequency = try(var.settings.finding_publishing_frequency, null)
}

resource "aws_macie2_organization_configuration" "this" {
  depends_on  = [aws_macie2_account.this]
  count       = try(var.settings.organization_enabled, false) ? 1 : 0
  auto_enable = true
}

resource "aws_macie2_organization_admin_account" "this" {
  depends_on       = [aws_macie2_account.this]
  count            = try(var.settings.admin_account_id, "") != "" ? 1 : 0
  admin_account_id = var.settings.admin_account_id
}

resource "aws_macie2_findings_filter" "finding_filter" {
  for_each    = try(var.settings.finding_filters, {})
  depends_on  = [aws_macie2_account.this]
  name        = each.value.name
  description = try(each.value.description, "")
  position    = try(each.value.position, null)
  action      = each.value.action
  finding_criteria {
    dynamic "criterion" {
      for_each = try(each.value.criterion, [])
      content {
        field          = try(criterion.value.field, null)
        eq_exact_match = try(criterion.value.eq_exact_match, null)
        eq             = try(criterion.value.eq, null)
        neq            = try(criterion.value.neq, null)
        lt             = try(criterion.value.lt, null)
        lte            = try(criterion.value.lte, null)
        gt             = try(criterion.value.gt, null)
        gte            = try(criterion.value.gte, null)
      }
    }
  }
  tags = merge(
    local.all_tags,
    {
      "Name" = each.value.name
    }
  )
}