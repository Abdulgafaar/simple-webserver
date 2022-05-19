data "aws_availability_zones" "azs" {

}

data "aws_elb_service_account" "main" {}

data "aws_ami" "webserver-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    sid = "1"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]


    resources = ["arn:aws:s3:::webserver-dev-lb-logs/*"]

  }

}
