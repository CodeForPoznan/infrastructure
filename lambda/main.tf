variable "name" {
  type = string
}
variable "runtime" {
  type = string
}
variable "handler" {
  type = string
}
variable "user_can_invoke" {
  type    = bool
  default = false
}
variable "memory_size" {
  type    = number
  default = 1024
}
variable "timeout" {
  type    = number
  default = 15
}

variable "s3_bucket" {}
variable "iam_user" {}
variable "additional_policies" {
  type    = list(any)
  default = []
}
variable "subnets" {
  type    = list(any)
  default = []
}
variable "security_groups" {
  type    = list(any)
  default = []
}
variable "envvars" {
  type    = map(any)
  default = {}
}

data "aws_iam_policy_document" "role" {
  version = "2012-10-17"

  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.role.json
}

resource "aws_iam_role_policy_attachment" "basic_role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
  count      = (length(var.subnets) * length(var.security_groups) != 0) ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "additional_role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.additional_policies[count.index].arn

  count = length(var.additional_policies)
}

resource "aws_s3_bucket_object" "object" {
  bucket = var.s3_bucket.id
  key    = "${var.name}.zip"
  // small zip with emtpy index.js
  content_base64 = "UEsDBBQACAAIAER0W1AAAAAAAAAAABkAAAAIACAAaW5kZXguanNVVA0AB1DFV17Gx1deUMVXXnV4CwABBOgDAAAE6AMAAEsrzUsuyczPU8hIzEvJSS1S0NBUqFao5eICAFBLBwjKJk4ZGwAAABkAAABQSwECFAMUAAgACABEdFtQyiZOGRsAAAAZAAAACAAgAAAAAAAAAAAApIEAAAAAaW5kZXguanNVVA0AB1DFV17Gx1deUMVXXnV4CwABBOgDAAAE6AMAAFBLBQYAAAAAAQABAFYAAABxAAAAAAA="

  depends_on = [
    var.s3_bucket,
  ]
}

resource "aws_lambda_function" "function" {
  function_name = replace(var.name, ".", "_")

  s3_bucket = var.s3_bucket.id
  s3_key    = aws_s3_bucket_object.object.key

  role    = aws_iam_role.role.arn
  handler = var.handler
  runtime = var.runtime

  memory_size = var.memory_size
  timeout     = var.timeout

  vpc_config {
    subnet_ids = [
      for subnet in var.subnets :
      subnet.id
    ]
    security_group_ids = [
      for security_group in var.security_groups :
      security_group.id
    ]
  }

  dynamic "environment" {
    for_each = (length(var.envvars) != 0) ? [1] : []

    content {
      variables = var.envvars
    }
  }

  depends_on = [
    aws_iam_role.role,
    aws_s3_bucket_object.object,
  ]
}

data "aws_iam_policy_document" "policy" {
  version = "2012-10-17"

  statement {
    sid       = "${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}S3"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.s3_bucket.arn}/${aws_s3_bucket_object.object.key}"]
  }

  statement {
    sid       = "${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}Lambda"
    effect    = "Allow"
    actions   = var.user_can_invoke ? ["lambda:UpdateFunctionCode", "lambda:InvokeFunction"] : ["lambda:UpdateFunctionCode"]
    resources = [aws_lambda_function.function.arn]
  }
}

resource "aws_iam_policy" "policy" {
  name   = var.name
  policy = data.aws_iam_policy_document.policy.json

  depends_on = [
    aws_s3_bucket_object.object,
  ]
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = var.iam_user.name
  policy_arn = aws_iam_policy.policy.arn

  depends_on = [
    aws_iam_policy.policy,
    var.iam_user,
  ]
}

output "function" {
  value     = aws_lambda_function.function
  sensitive = true
}
