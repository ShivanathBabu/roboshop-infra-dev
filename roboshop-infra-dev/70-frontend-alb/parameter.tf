resource "aws_ssm_parameter" "frontend_alb_listner_arn" {
  name = "/${var.project}/${var.environment}/frontend_alb_listner_arn"
  type = "String"
  value = aws_alb_listener.frontend_alb.arn 
}