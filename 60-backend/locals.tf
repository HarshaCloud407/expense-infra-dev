locals {
  # =======================================================
  # PRIVATE SUBNETS
  # =======================================================

  private_subnet_ids = split(
    ",",
    data.aws_ssm_parameter.private_subnet_ids.value
  )

  private_subnet_id = local.private_subnet_ids[0]


  # =======================================================
  # RESOURCE NAME
  # =======================================================

  resource_name = "${var.project_name}-${var.environment}-backend"


  # =======================================================
  # VPC
  # =======================================================

  vpc_id = data.aws_ssm_parameter.vpc_id.value


  # =======================================================
  # BACKEND SECURITY GROUP
  # =======================================================

  backend_sg_id = data.aws_ssm_parameter.backend_sg_id.value
}