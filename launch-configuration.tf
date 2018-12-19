resource "aws_key_pair" "deployer" {
  key_name    = "ec2-ecs"
  public_key = "${file("${var.ssh-public-key}")}"
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                 = "ecs-launh-configuration"
  image_id             = "ami-fad25980"
  instance_type        = "t2.xlarge"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"
  key_name             = "${aws_key_pair.deployer.key_name}"

  root_block_device {
    volume_type = "standard"
    volume_size = 40
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.web_inbound.id}"]
  associate_public_ip_address = "true"
  user_data                   = "#!/bin/bash\necho 'ECS_CLUSTER=cluster-pse\nECS_ENGINE_AUTH_TYPE=dockercfg\nECS_ENGINE_AUTH_DATA={\"$URL\":{\"auth\":\"$AUTH\",\"email\":\"$EMAIL\"}}' > /etc/ecs/ecs.config"
}
