resource "aws_ssm_parameter" "db_creds" {
  name        = "/myapp/database/creds"
  type        = "SecureString" 
  overwrite   = true
  value = jsonencode({
    POSTGRES_DB = "islamic_app"
    POSTGRES_USER = "islamic_user"
    POSTGRES_PASSWORD     = "islamic_pass123"
    POSTGRES_HOST_AUTH_METHOD     = "trust"
  })

}

resource "aws_ssm_parameter" "back_creds" {
  name        = "/myapp/back/creds"
  type        = "SecureString" 
  overwrite   = true
  value = jsonencode({
    DATABASE_URL = "postgresql://islamic_user:islamic_pass123@db-svc:5432/islamic_app"
    SECRET_KEY = "SecrEt@123!"
    JWT_SECRET_KEY     = "SecrEt@123!"
  })

}
