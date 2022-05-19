resource "aws_launch_configuration" "webserver-LC" {
  name                   = "Bestseller-LC"
#  image_id               = data.aws_ami.webserver-ami.image_id
  image_id               = data.aws_ami.webserver-ami.image_id
  instance_type          = "t2.micro"
  security_groups        = [aws_security_group.webserver-SG.id]
  key_name               = aws_key_pair.webserver-key.key_name
  iam_instance_profile = aws_iam_instance_profile.SSM-profile.name


  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get -y update
              sudo apt-get -y install nginx
              sudo apt-get -y install httpd
              systemctl start httpd
              systemctl enable httpd
              echo 'Hello world!' >> /var/www/html/index.html
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webserver-ASG" {
  launch_configuration = aws_launch_configuration.webserver-LC.name
  min_size = 1
  max_size = 3
#  load_balancers = [aws_lb.webserver-ELB.name]
  health_check_type = "ELB"
  vpc_zone_identifier = [for subnet in var.private-subnets : subnet.id]
  tag {
    key                 = "Name"
    value               = "webserver-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "alb-attachment" {
  autoscaling_group_name = aws_autoscaling_group.webserver-ASG.id
  alb_target_group_arn = aws_lb_target_group.webserver-TG.arn
}

resource "aws_autoscaling_policy" "scaling-policy" {
  autoscaling_group_name = aws_autoscaling_group.webserver-ASG.name
  name                   = "webserver-scale-down"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "webserver-cpu-alarm" {
  alarm_name          = "webserver-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  alarm_description   = "alarm when the cpu goes up"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "80"
  dimensions          =   {
    "AutoScalingGroupName": aws_autoscaling_group.webserver-ASG.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scaling-policy.arn]
}

resource "aws_autoscaling_policy" "scaling-down-policy" {
  autoscaling_group_name = aws_autoscaling_group.webserver-ASG.name
  name                   = "scale-down-cpu-policy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"

}

resource "aws_cloudwatch_metric_alarm" "webserver-scaledown-cpu-alarm" {
  alarm_name          = "webserver-scaledown--cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  alarm_description = "alarm when the cpu goes up"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = "60"
  dimensions = {
    "AutoScalingGroupName": aws_autoscaling_group.webserver-ASG.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.scaling-down-policy.arn]
}