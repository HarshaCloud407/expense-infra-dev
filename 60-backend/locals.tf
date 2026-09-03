locals {
  # -------------------------------------------------------
  # Private Subnets
  # -------------------------------------------------------

  private_subnet_ids = split(
    ",",
    data.aws_ssm_parameter.private_subnet_ids.value
  )

  private_subnet_id = local.private_subnet_ids[0]

  # -------------------------------------------------------
  # Resource Name
  # -------------------------------------------------------

  resource_name = "${var.project_name}-${var.environment}-backend"

  # -------------------------------------------------------
  # VPC
  # -------------------------------------------------------

  vpc_id = data.aws_ssm_parameter.vpc_id.value

  # -------------------------------------------------------
  # Backend Security Group
  # -------------------------------------------------------

  backend_sg_id = data.aws_ssm_parameter.backend_sg_id.value
}