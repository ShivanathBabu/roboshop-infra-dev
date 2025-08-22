resource "aws_ssm_parameter" "backend_alb_listner_arn" {
  name = "/${var.project}/${var.environment}/backend_alb_listner_arn"
  type = "String"
  value = aws_alb_listener.backend_alb.arn 
}