resource "aws_ssm_parameter" "aws_acm_certificate_arm" {
  name = "/${var.project}/${var.environment}/acm_certificate_arn"
  type = "String"
  value = aws_acm_certificate.blackwebagency.arn
}