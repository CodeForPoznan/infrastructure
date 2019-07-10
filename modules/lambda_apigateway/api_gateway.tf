
variable "rest_api_name" {}
variable "api_gw_description" {}
variable "rest_resource_path_part" {}
variable "stage" {}


resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${var.rest_api_name}"
  description = "${var.api_gw_description}"
}

resource "aws_api_gateway_resource" "rest_api_resource" {
    rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
    parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
    path_part = "${var.rest_resource_path_part}"
}

resource "aws_api_gateway_method" "rest_api_method" {
    rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
    resource_id = "${aws_api_gateway_resource.rest_api_resource.id}"
    http_method = "ANY"
    authorization = "NONE"
    api_key_required = "false"
}

resource "aws_api_gateway_integration" "rest_api_integration" {
    rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
    resource_id = "${aws_api_gateway_resource.rest_api_resource.id}"
    http_method = "${aws_api_gateway_method.rest_api_method.http_method}"
    type = "AWS_PROXY"
    uri = "${aws_lambda_function.lambda_function.invoke_arn}"
    integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
    depends_on = [
        "aws_api_gateway_method.rest_api_method",
        "aws_api_gateway_integration.rest_api_integration"
    ]
    rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
    stage_name = "${var.stage}"
}
