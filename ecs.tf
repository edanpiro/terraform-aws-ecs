resource "aws_ecs_cluster" "cluster_pse" {
  name = "cluster-pse"
}

resource "aws_ecs_task_definition" "task_api_document" {
  family                   = "api-document"
  container_definitions    = "${file("task-definitions/api-document.json")}"
#  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "service_api_document" {
  name            = "service-api-document"
  iam_role        = "${aws_iam_role.ecs-service-role.name}"
  cluster         = "${aws_ecs_cluster.cluster_pse.id}"
  task_definition = "${aws_ecs_task_definition.task_api_document.arn}"
  desired_count   = 1
  
  load_balancer {
    target_group_arn = "${aws_alb_target_group.lb_target_service.arn}"
    container_name   = "api-document"
    container_port   = 80
  }

}
