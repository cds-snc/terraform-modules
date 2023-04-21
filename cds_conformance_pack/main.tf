/* # cds_conformance_pack
*
*/

resource "aws_config_conformance_pack" "cds_conformance_pack" {
  name = "cds_conformance_pack"

  input_parameter {
    parameter_name  = "InternetGatewayAuthorizedVpcOnlyParamAuthorizedVpcIds"
    parameter_value = var.authorized_vpc_ids
  }

  template_body = file("${path.module}/Operational-Best-Practices-for-CCCS-Medium.yaml")

  depends_on = [aws_config_configuration_recorder.cds_conformance_pack]
}

resource "aws_config_configuration_recorder" "cds_conformance_pack" {
  name     = "cds_conformance_pack"
  role_arn = aws_iam_role.cds_conformance_pack.arn
}

data "aws_iam_policy_document" "cds_conformance_pack_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cds_conformance_pack" {
  name               = "cds_conformance_pack"
  assume_role_policy = data.aws_iam_policy_document.cds_conformance_pack_assume_role.json
}
