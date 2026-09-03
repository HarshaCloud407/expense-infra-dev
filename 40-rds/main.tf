module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.1"

  identifier = local.resource_name # expense-dev

  # ---------------------------------------------------------
  # RDS Engine
  # ---------------------------------------------------------
  engine            = "mysql"
  engine_version    = "8.0.40"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  # ---------------------------------------------------------
  # Database
  # ---------------------------------------------------------
  db_name  = "transactions"
  username = "root"
  port     = 3306

  # RDS module v7.2.1
  password_wo         = var.db_password
  password_wo_version = 1

  manage_master_user_password = false

  # ---------------------------------------------------------
  # Security Group
  # ---------------------------------------------------------
  vpc_security_group_ids = [local.mysql_sg_id]

  # ---------------------------------------------------------
  # DB subnet group
  # ---------------------------------------------------------
  create_db_subnet_group = false
  db_subnet_group_name   = local.database_subnet_group_name

  # ---------------------------------------------------------
  # DB parameter group
  # ---------------------------------------------------------
  family = "mysql8.0"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  # ---------------------------------------------------------
  # Database deletion protection
  # ---------------------------------------------------------
  deletion_protection = false
  skip_final_snapshot = true

  # ---------------------------------------------------------
  # Tags
  # ---------------------------------------------------------
  tags = merge(
    var.common_tags,
    {
      Name = local.resource_name
    }
  )
}

# -------------------------------------------------------------
# Route53 DNS record
# -------------------------------------------------------------

resource "aws_route53_record" "www-dev" {
  zone_id = var.zone_id

  name = "mysql-${var.environment}.${var.domain_name}"

  type = "CNAME"
  ttl  = 5

  records = [
    module.db.db_instance_address
  ]
}
