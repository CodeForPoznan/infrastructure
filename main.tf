terraform {
  backend "s3" { }
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "default"
}

module "alinka_website" {
  source = "./modules/lambda_apigateway"
  
  # LAMBDA VARS 
  function_name = "alina-email-sender"
  filename = "./modules/lambda_apigateway/index.js" 
  lambda_description = "${var.lambda_description}"
  handler = "${var.handler}"
  runtime = "${var.runtime}"
  stage = "${var.stage}"
  path_part = "${var.path_part}"


  # APIGATEWAY VARS
  rest_api_name = "${var.rest_api_name}"
  rest_resource_path_part = "${var.rest_resource_path_part}"
  api_gw_description = "${var.api_gw_description}"


  # IAM VARS
  iam_role_name = "${var.iam_role_name}"
  iam_role_policy_name = "${var.iam_role_policy_name}"

  # SES VARS
  domain = "${var.domain}"
  zone_id = "${var.zone_id}"
}
