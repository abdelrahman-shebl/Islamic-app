resource "aws_ssm_parameter" "db_creds" {
  name      = "/myapp/database/creds"
  type      = "SecureString"
  overwrite = true
  value     = jsonencode({
    POSTGRES_DB              = local.secrets.db_name
    POSTGRES_USER            = local.secrets.db_user
    POSTGRES_PASSWORD        = local.secrets.db_password
    POSTGRES_HOST_AUTH_METHOD = "trust"
  })
}

resource "aws_ssm_parameter" "back_creds" {
  name      = "/myapp/back/creds"
  type      = "SecureString"
  overwrite = true
  value     = jsonencode({
    DATABASE_URL    = "postgresql://${local.secrets.db_user}:${local.secrets.db_password}@db-svc:5432/${local.secrets.db_name}"
    SECRET_KEY      = local.secrets.back_secret_key
    JWT_SECRET_KEY  = local.secrets.jwt_secret_key
  })
}
