#############################################################################
# VARIABLES
#############################################################################

variable "region" {
  type = string
  default = "us-east-2"
}

#############################################################################
# PROVIDERS
#############################################################################

provider "aws" {
  region = var.region
}

#############################################################################
# DATA SOURCES
#############################################################################

data "aws_iam_role" "existing_lambda_role" {
  name = "production.lambda-execute.role"
}

#############################################################################
# RESOURCES
#############################################################################  

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "MinimalAPI-Dotnet"
  description   = "API function for training purposes using the 'serverless.AspNetCoreMinimalAPI' template."
  handler       = "MinimalAPI-Dotnet.Function"
  runtime       = "dotnet8"
  create_role   = false
  #lambda_role  = aws_iam_role.lambda_role.arn
  lambda_role   = data.aws_iam_role.existing_lambda_role.arn
  tracing_mode  = "Active"
  publish       = true
  architectures = ["arm64"]

  environment_variables = {
    ENV = "Production"
  }

  tags = {
    Name        = "MinimalAPI-Dotnet.Function"
    Environment = "Sandbox"
    Repository  = "https://github.com/CurtisLawhorn/MinimalAPI-Dotnet.Function.git"
  }

  source_path = [{
    path = "../../src"
    commands = [
      "dotnet restore",
      "dotnet publish -c Release -r linux-arm64 -o publish",
      "cd ./publish",
      ":zip"
    ]
  }]

  #attach_policy_statements = true
  #policy_statements = {
  #  cloud_watch = {
  #    effect    = "Allow",
  #    actions   = ["cloudwatch:PutMetricData"],
  #    resources = ["*"]
  #  }
  #}
  
}

#resource "aws_iam_role" "lambda_role" {
#  name = "production.lambda-execute2.role"
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [{
#      Action = "sts:AssumeRole",
#      Effect = "Allow",
#      Principal = {
#        Service = "lambda.amazonaws.com",
#      },
#    }],
#  })
#}

#resource "aws_iam_policy" "lambda_policy" {
#  name   = "lambda_policy"
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [{
#      Action = [
#        "logs:CreateLogGroup",
#        "logs:CreateLogStream",
#        "logs:PutLogEvents",
#      ],
#      Effect   = "Allow",
#      Resource = "*",
#      #Resource = "arn:aws:logs:*:*:*",
#    }],
#  })
#}

#resource "aws_iam_role_policy_attachment" "lambda_logs" {
#  #role      = aws_iam_role.lambda_role.name
#  role       = data.aws_iam_role.existing_lambda_role.name
#  policy_arn = aws_iam_policy.lambda_policy.arn
#}

#############################################################################
# OUTPUTS
#############################################################################

