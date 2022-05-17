resource "aws_launch_configuration" "webserver-LC" {
  image_id               = data.aws_ami.webserver-ami.image_id
  instance_type          = "t2.micro"
#  security_groups        = aws_security_group.webserver-SG
  key_name               = aws_key_pair.webserver-key.key_name
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "webserver-ASG" {
  launch_configuration = aws_launch_configuration.webserver-LC.name
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  min_size = 1
  max_size = 3
  load_balancers = [aws_lb.webserver-ELB.id]
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    value               = "webserver-asg"
    propagate_at_launch = true
  }
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