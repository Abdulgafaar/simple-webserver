
resource "aws_key_pair" "webserver-key" {
  key_name = "webserver-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCc43z/UKxDqqN1jV6YrEI7whYhrZOin8GeTOsUDA3OKhkhbARYHyxa9HctI2Rqj17m8pUyFjg+e37KJfrBW/XPyF9yv+MHNEK5cWQgyiNQuPUDDwEomGJLw87RfWXFE0/7ed5AGSttY0LfvfFR2JM7pxf9DPOEDMT9kvjrTjcjatE5nhRE+MGERUs/2Ap4Jg6aBzcbZ3dg7k+sjnjlUU4tj3hV+k6urKNT+H/REqukihicjWukPXQ8MNlQ2ZkJbyv6J10yX2nEQSKIbNcQKV4++/nx7c0uoGOwmfiGdcQyuT4HEoy5CNzVK1G2hWymBd5WpkOba7yiLjgXnhhK/hAh abdulgafaar@abdulgafaar-HP-15-Notebook-PC"
}

resource "aws_iam_role" "ec2role" {
  name = "webserver-iam-role"
#  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"

  }
}



resource "aws_iam_instance_profile" "SSM-profile" {
  name = "webserver-profile"
  role = aws_iam_role.ec2role.name
}

resource "aws_iam_role_policy" "web_iam_role_policy" {
  name = "web_iam_role_policy"
  role = aws_iam_role.ec2role.id
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Action": ["s3:*"],
			"Resource": "*"
		}

	]
}
EOF
}



# creation logs to be pushed by cloudwatch
resource "aws_s3_bucket" "lb-logs" {
  bucket = "webserver-dev-lb-logs"
  acl    = "private"


  versioning {
    enabled = true
  }

  tags = merge(local.tags, {
    name = "${var.resource-identifier}-lb-logs"

  })
}
resource "aws_s3_bucket_policy" "allow-access-to-logs" {
  bucket = aws_s3_bucket.lb-logs.id
  policy = data.aws_iam_policy_document.instance-assume-role-policy.json
#  policy = data.template_file.policy-file.rendered
}

resource "aws_s3_bucket_acl" "lb-logs" {
  bucket = aws_s3_bucket.lb-logs.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  bucket = aws_s3_bucket.lb-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Target group creation

resource "aws_lb_target_group" "webserver-TG" {
  name = "webserver-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc

}

# ALB creation
resource "aws_lb" "webserver-ELB" {
  name = "webserver-ALB"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.elb-SG.id]
  subnets = [for subnet in var.public-subnets : subnet.id]
  enable_cross_zone_load_balancing = true


  access_logs {
    bucket  = aws_s3_bucket.lb-logs.bucket
    prefix  = "webserver-lb"
    enabled = true
  }

  depends_on = [var.vpc]

}
# Webserver listener creation
resource "aws_lb_listener" "front-end" {
  load_balancer_arn = aws_lb.webserver-ELB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.webserver-TG.arn
    type = "forward"


  }
}

