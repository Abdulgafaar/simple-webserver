

resource "aws_key_pair" "webserver-key" {
  key_name = "webserver-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCc43z/UKxDqqN1jV6YrEI7whYhrZOin8GeTOsUDA3OKhkhbARYHyxa9HctI2Rqj17m8pUyFjg+e37KJfrBW/XPyF9yv+MHNEK5cWQgyiNQuPUDDwEomGJLw87RfWXFE0/7ed5AGSttY0LfvfFR2JM7pxf9DPOEDMT9kvjrTjcjatE5nhRE+MGERUs/2Ap4Jg6aBzcbZ3dg7k+sjnjlUU4tj3hV+k6urKNT+H/REqukihicjWukPXQ8MNlQ2ZkJbyv6J10yX2nEQSKIbNcQKV4++/nx7c0uoGOwmfiGdcQyuT4HEoy5CNzVK1G2hWymBd5WpkOba7yiLjgXnhhK/hAh abdulgafaar@abdulgafaar-HP-15-Notebook-PC"
}

resource "aws_iam_role" "ec2role-ssm" {
  name = "webserver-iam-role"
  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "ec2.amazonaws.com"
		},
		"Effect": "Allow",
		"Sid": ""
	}]
}
EOF

  tags = {
    tag-key = "tag-value"

  }
}

resource "aws_iam_group_policy_attachment" "ec2-ssm-policy" {
  group = aws_iam_group.group.name
#  group = aws_iam_role.ec2role-ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

resource "aws_iam_group" "group" {
  name = "iam-group"
}

resource "aws_iam_instance_profile" "SSM-profile" {
  name = "webserver-profile"
  role = "webserver-iam-role"
}

resource "aws_iam_role_policy" "web_iam_role_policy" {
  name = "web_iam_role_policy"
  role = aws_iam_role.ec2role-ssm.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::webserver-dev-lb-logs"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::webserver-dev-lb-logs/*"]
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


resource "aws_network_interface" "webserver-interface" {
  subnet_id   = local.private-subnets[0].id

}

resource "aws_instance" "webserver-instance" {
  ami                  = data.aws_ami.webserver-ami.id
  instance_type        = var.instance-type
  key_name             = aws_key_pair.webserver-key.key_name
  iam_instance_profile = aws_iam_instance_profile.SSM-profile.id


  network_interface {
    network_interface_id = aws_network_interface.webserver-interface.id
    device_index         = 0
  }

  tags = {
    Name        = "Webserver-instance"
    Environment = "dev"

  }

  timeouts {
    create = "10m"
  }

}


# Target group creation

resource "aws_lb_target_group" "webserver-TG" {
  name = "webserver-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc

}

# Target group attachment
resource "aws_lb_target_group_attachment" "webserver-TG-attach" {
  target_group_arn = aws_lb_target_group.webserver-TG.arn
  target_id        = aws_lb.webserver-ELB.arn
}
# ALB creation
resource "aws_lb" "webserver-ELB" {
  name = "webserver-ALB"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.elb-SG.id]
  subnets = [for subnet in var.public-subnets : subnet.id]


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
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# creation of the ALB listener rule
 resource "aws_lb_listener_rule" "static" {
   listener_arn = aws_lb_listener.front-end.arn
   priority = 100
   action {
     type = "forward"
     target_group_arn = aws_lb_target_group.webserver-TG.arn
   }
   condition {
     path_pattern {
       values = ["/var/www/html/index.html"]
     }
   }
 }

