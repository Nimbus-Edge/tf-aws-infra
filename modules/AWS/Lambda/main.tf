data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = var.zip_path
  output_path = "lambda_package.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "my-lambda-function-1"
  runtime          = var.runtime
  role             = var.role_arn
  handler          = "index.handler"
  filename         = "lambda_package.zip"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  environment {
    variables = {
      SENDGRID_FROM_EMAIL = var.sendgrid_from_email
      VERIFY_URL_BASE     = var.verify_url_base
      EMAIL_SECRET_KEY    = var.email_secret_key
    }
  }
  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
}
