resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "ecs-autoscaling-group"
  max_size             = 7 
  min_size             = 6 
  desired_capacity     = 6 
  vpc_zone_identifier  = ["${aws_subnet.backend.*.id}"]
  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type    = "ELB"
}
