# Provider configuration
provider "aws" {
  region = "ap-south-1"  # Adjust to your desired region
}

# ECS Cluster Definition
resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-app-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition for Medusa
resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"   # Adjust based on your needs
  memory                   = "512"   # Adjust based on your needs

  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn  # This is required for Fargate to pull images from ECR

  container_definitions = jsonencode([{
  name      = "medusa"
  image     = "851725658887.dkr.ecr.ap-south-1.amazonaws.com/medusa-app:latest"  # Update to ap-south-1 region
  essential = true
  portMappings = [{
    containerPort = 9000
    hostPort      = 9000
    protocol      = "tcp"
  }]
}])
}

# ECS Service Definition for Fargate
resource "aws_ecs_service" "medusa_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0f20558a7188da68a"]  # Replace with your actual subnet ID
    security_groups = ["sg-01e6f3d9fc0a67daf"]  # Replace with your actual security group ID
    assign_public_ip = true  # Ensure the task gets a public IP
  }
}

# App AutoScaling Target
resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.medusa_cluster.name}/${aws_ecs_service.medusa_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CloudWatch Alarm for High CPU (Scaling Up)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "High CPU Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75  # Scale up if CPU exceeds 75%
  alarm_description   = "This alarm will trigger scaling the ECS service."

  dimensions = {
    ClusterName = aws_ecs_cluster.medusa_cluster.name
    ServiceName = aws_ecs_service.medusa_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_policy.arn]  # Reference the combined scaling policy
}

# CloudWatch Alarm for Low CPU (Scaling Down)
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "Low CPU Alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 30  # Scale down if CPU drops below 30%
  alarm_description   = "This alarm will trigger scaling the ECS service."

  dimensions = {
    ClusterName = aws_ecs_cluster.medusa_cluster.name
    ServiceName = aws_ecs_service.medusa_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_policy.arn]  # Reference the combined scaling policy
}

# Combined Scaling Policy for Scaling Up and Down based on CPU Utilization
resource "aws_appautoscaling_policy" "scale_policy" {
  name                   = "scale-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.ecs_scaling_target.id
  scalable_dimension     = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50.0  # Target 50% CPU utilization
    scale_out_cooldown = 60
    scale_in_cooldown  = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"  # Track CPU Utilization for scaling
    }
  }
}

# Outputs
output "cluster_id" {
  value = aws_ecs_cluster.medusa_cluster.id
}

output "service_name" {
  value = aws_ecs_service.medusa_service.name
}
