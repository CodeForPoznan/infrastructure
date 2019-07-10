variable "function_name" {}
variable "filename" {}
variable "lambda_description" {}
variable "handler" {}
variable "runtime" {}
variable "path_part" {}


#### MOCK LAMBDA

resource "null_resource" "build_lambda_zip" {
    provisioner "local-exec"{
        command = <<COMMAND
cp -r --update ${var.filename} ./lambda
COMMAND
    }

    triggers {
        uuid = "${uuid()}"
    }
}

data "archive_file" "lambda_zip" {
    depends_on = ["null_resource.build_lambda_zip"]

    type = "zip"
    source_dir = "lambda"
    output_path = "lambda.zip"
}

resource "null_resource" "clean" {
    depends_on = ["aws_lambda_function.lambda_function"]

    provisioner "local-exec"{
        command = <<COMMAND
rm -rf ${data.archive_file.lambda_zip.output_path}
COMMAND
    }

    triggers {
        uuid = "${uuid()}"
    }
}

####

resource "aws_lambda_function" "lambda_function" {
    depends_on = ["data.archive_file.lambda_zip"]

    function_name = "${var.function_name}"
    
    # Basic lambda function code required during first creation
    filename = "lambda.zip"
    
    role = "${aws_iam_role.iam_role.arn}"
    description = "${var.lambda_description}"
    handler = "${var.handler}"
    runtime = "${var.runtime}"

    environment {
        variables {
            name = "${var.function_name}-${var.stage}"
        }
    }
}

resource "aws_lambda_permission" "allow_api_gateway" {
    function_name = "${aws_lambda_function.lambda_function.function_name}"
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    principal     = "apigateway.amazonaws.com"
    source_arn = "${replace(aws_api_gateway_deployment.rest_api_deployment.execution_arn, "${var.stage}", "")}*/*"
}
