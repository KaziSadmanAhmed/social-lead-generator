terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Define variables
variable "env" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "social-lead-generator"
}

variable "app_name" {
  description = "App name"
  type        = string
  default     = "Social Lead Generator"
}

variable "admin_email" {
  description = "Admin email"
  type        = string
  default     = "hello@sadman.xyz"
}

variable "env_secret" {
  description = "Environment Secret Key"
  type        = string
  default     = "top secret key"

}

variable "api_allowed_origins" {
  description = "API Allowed Origins"
  type        = string
  default     = "*"
}

variable "db_name" {
  description = "DB name"
  type        = string
  default     = "postgres"
}

variable "db_user" {
  description = "DB user"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "DB password"
  type        = string
  default     = "postgres"
}

variable "twitter_consumer_key" {
  description = "Twitter Comsumer Key"
  type        = string
  default     = "twitter consumer key"
}

variable "twitter_consumer_secret" {
  description = "Twitter Comsumer Key"
  type        = string
  default     = "twitter consumer secret"
}

variable "twitter_callback_url" {
  description = "Twitter Callback Url"
  type        = string
  default     = "http://127.0.0.1:3000/auth/twitter/callback"

}

variable "private_subnet_cidrs" {
  description = "Private Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "az_names" {
  description = "AZ names"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ecs_ami_id" {
  description = "ECS optimized Amazon Linux 2 AMI ID"
  type        = string
  default     = "ami-00bf0e20ed7ea8cdc"
}

variable "ec2_container_service_role_arn" {
  description = "EC2 Container Service Role ARN"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

variable "ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "ec2_ssh_key" {
  description = "EC2 SSH KEY"
  type        = string
  default     = "sadman"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Region data
data "aws_region" "current" {}

# Create main VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.prefix}-vpc-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create VPC private subnets
resource "aws_subnet" "private" {
  count             = length(var.az_names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.az_names, count.index)

  tags = {
    Name        = "${var.prefix}-private-subnet-${substr(element(var.az_names, count.index), -2, -1)}-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create VPC public subnets
resource "aws_subnet" "public" {
  count                   = length(var.az_names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.az_names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.prefix}-public-subnet-${substr(element(var.az_names, count.index), -2, -1)}-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create Internet GW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.prefix}-main-igw-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create EIP
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name        = "${var.prefix}-eip-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create NAT GW
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "${var.prefix}-nat-gw-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# Create private route table
resource "aws_route_table" "private" {
  depends_on = [
    aws_nat_gateway.main
  ]
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.prefix}-private-rt-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Create public route table
resource "aws_route_table" "public" {
  depends_on = [
    aws_internet_gateway.main
  ]
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.prefix}-public-rt-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2" {
  name        = "${var.prefix}-ec2-sg-${var.env}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_app" {
  name        = "${var.prefix}-alb-app-sg-${var.env}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create LB target group for db
resource "aws_lb_target_group" "db" {
  name        = "${var.prefix}-db-${var.env}"
  port        = 5432
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.prefix}-tg-db-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create a NLB for db
resource "aws_lb" "db" {
  name               = "${var.prefix}-db-${var.env}"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false

  tags = {
    Name        = "${var.prefix}-lb-db-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create LB listener for db
resource "aws_lb_listener" "db" {
  load_balancer_arn = aws_lb.db.arn
  port              = "5432"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.db.arn
  }

  tags = {
    Name        = "${var.prefix}-lb-listener-db-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create LB target group for api
resource "aws_lb_target_group" "api" {
  name        = "${var.prefix}-api-${var.env}"
  port        = 8000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path = "/api/v1/healthcheck/status"
  }

  tags = {
    Name        = "${var.prefix}-tg-api-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create LB target group for webapp
resource "aws_lb_target_group" "webapp" {
  name        = "${var.prefix}-wapp-${var.env}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.prefix}-tg-wapp-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create a ALB for api and webapp
resource "aws_lb" "app" {
  name               = "${var.prefix}-app-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_app.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false

  tags = {
    Name        = "${var.prefix}-lb-app-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create LB listener for api
resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.app.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = {
    Name        = "${var.prefix}-lb-listener-api-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create LB listener for webapp
resource "aws_lb_listener" "webapp" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp.arn
  }

  tags = {
    Name        = "${var.prefix}-lb-listener-wapp-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create ECS task execution role and policy
data "aws_iam_policy_document" "ecs_task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name                = "ecs_task_execution"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task-assume-role-policy.json
  managed_policy_arns = [var.ec2_container_service_role_arn]
}

# Create ECS EC2 instance role and policy
data "aws_iam_policy_document" "ec2_assume_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_container_role" {
  name                = "ec2_container_role"
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_trust_policy.json
  managed_policy_arns = [var.ec2_container_service_role_arn]
}

resource "aws_iam_instance_profile" "ec2_container_instance_profile" {
  name = "ec2_container_instance_profile"
  role = aws_iam_role.ec2_container_role.name
}

# Create ECS container log group for db
resource "aws_cloudwatch_log_group" "ecs_task_db" {
  name = "${var.prefix}-ecs-task-log-group-db-${var.env}"

  tags = {
    Name        = "${var.prefix}-ecs-task-log-group-db-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create ECS container log group for api
resource "aws_cloudwatch_log_group" "ecs_task_api" {
  name = "${var.prefix}-ecs-task-log-group-api-${var.env}"

  tags = {
    Name        = "${var.prefix}-ecs-task-log-group-api-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create ECS container log group for webapp
resource "aws_cloudwatch_log_group" "ecs_task_webapp" {
  name = "${var.prefix}-ecs-task-log-group-wapp-${var.env}"

  tags = {
    Name        = "${var.prefix}-ecs-task-log-group-wapp-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create service discovery resources
resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "${var.prefix}-${var.env}"
  vpc  = aws_vpc.main.id
}

resource "aws_service_discovery_service" "db" {
  name = "db"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "api" {
  name = "api"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "webapp" {
  name = "webapp"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# data "aws_ami" "ecs_ami" {
#   most_recent = true # get the latest version
#
#   filter {
#     name = "name"
#     values = [
#     "amzn2-ami-ecs-*"] # ECS optimized image
#   }
#
#   owners = [
#     "amazon" # Only official images
#   ]
# }

resource "aws_launch_configuration" "ecs_launch_config" {
  name                 = "ecs-ec2-launch-config"
  image_id             = var.ecs_ami_id
  security_groups      = [aws_security_group.ec2.id]
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_container_instance_profile.name
  user_data            = <<EOF
#!/bin/bash
echo "ECS_CLUSTER=${var.prefix}-cluster-${var.env}" >> /etc/ecs/ecs.config
  EOF
  # key_name             = var.ec2_ssh_key
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "asg"
  vpc_zone_identifier  = aws_subnet.private.*.id
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "1"
  health_check_grace_period = 150
  health_check_type         = "EC2"
}

# Create main ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster-${var.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create ECS Task Definition for db
resource "aws_ecs_task_definition" "db" {
  family                   = "${var.prefix}-db-${var.env}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  # task_role_arn            = aws_iam_role.ecsTaskExecution_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "${var.prefix}-db-${var.env}"
      image     = "postgres:14-alpine"
      cpu       = 128
      memory    = 256
      essential = true

      portMappings = [
        {
          containerPort = 5432
          hostPort      = 0
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "pg_isready -U postgres || exit 1"]
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task_db.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "/ecs"
        }

      }
      environment = [
        {
          name  = "POSTGRES_DB"
          value = var.db_name
        },

        {
          name  = "POSTGRES_USER"
          value = var.db_user
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = var.db_password
        }
      ]
    }
  ])

  tags = {
    Name        = "${var.prefix}-db-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create ECS service/task for db
resource "aws_ecs_service" "db" {
  name            = "${var.prefix}-db-${var.env}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.db.arn
  desired_count   = 1
  launch_type     = "EC2"
  # iam_role        = aws_iam_role.ecsTaskExecution_role.arn
  # depends_on = [aws_iam_role.ecsTaskExecution_role]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.db.arn
    container_port = 5432
    container_name = "${var.prefix}-db-${var.env}"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.db.arn
    container_name   = "${var.prefix}-db-${var.env}"
    container_port   = 5432
  }

  # network_configuration {
  #   subnets = [for subnet in aws_subnet.private : subnet.id]
  # }
}

# Create ECS Task Definition for api
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.prefix}-api-${var.env}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  # task_role_arn            = aws_iam_role.ecsTaskExecution_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "${var.prefix}-api-${var.env}"
      image     = "sadmanahmed/social-lead-generator_api:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 0
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task_api.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "/ecs"
        }
      }
      environment = [
        {
          name  = "ENV"
          value = var.env
        },
        {
          name  = "PREFIX"
          value = var.prefix
        },
        {
          name  = "APP_NAME"
          value = var.app_name
        },
        {
          name  = "ADMIN_EMAIL"
          value = var.admin_email
        },
        {
          name  = "DB_HOST"
          value = "db.${var.prefix}-${var.env}"
        },
        {
          name  = "DB_HOST_DNS_RECORD_TYPE"
          value = "SRV"
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_user
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        },
        {
          name  = "SECRET_KEY"
          value = var.env_secret
        },
        {
          name  = "HASH_ALGO"
          value = "HS512"
        },
        {
          name  = "ACCESS_TOKEN_EXPIRATION"
          value = "86400"
        },
        {
          name  = "ALLOWED_ORIGINS"
          value = var.api_allowed_origins
        },
        {
          name  = "TWITTER_CONSUMER_KEY"
          value = var.twitter_consumer_key
        },
        {
          name  = "TWITTER_CONSUMER_SECRET"
          value = var.twitter_consumer_secret
        },
        {
          name  = "TWITTER_CALLBACK_URL"
          value = var.twitter_callback_url
        }
      ]
    }
  ])

  tags = {
    Name        = "${var.prefix}-api-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create ECS service/task for api
resource "aws_ecs_service" "api" {
  name            = "${var.prefix}-api-${var.env}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "EC2"
  # iam_role        = aws_iam_role.ecsTaskExecution_role.arn
  # depends_on = [aws_iam_role.ecsTaskExecution_role]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.api.arn
    container_port = 8000
    container_name = "${var.prefix}-api-${var.env}"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "${var.prefix}-api-${var.env}"
    container_port   = 8000
  }

  depends_on = [
    aws_ecs_service.db,
    aws_service_discovery_service.db
  ]
}

# Create ECS Task Definition for webapp
resource "aws_ecs_task_definition" "webapp" {
  family                   = "${var.prefix}-wapp-${var.env}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  # task_role_arn            = aws_iam_role.ecsTaskExecution_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "${var.prefix}-wapp-${var.env}"
      image     = "sadmanahmed/social-lead-generator_webapp:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task_webapp.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "/ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.prefix}-wapp-${var.env}"
    Application = "${var.prefix}"
    Environment = "${var.env}"
  }
}

# Create ECS service/task for webapp
resource "aws_ecs_service" "webapp" {
  name            = "${var.prefix}-wapp-${var.env}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.webapp.arn
  desired_count   = 1
  launch_type     = "EC2"
  # iam_role        = aws_iam_role.ecsTaskExecution_role.arn
  # depends_on = [aws_iam_role.ecsTaskExecution_role]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.webapp.arn
    container_port = 80
    container_name = "${var.prefix}-wapp-${var.env}"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.webapp.arn
    container_name   = "${var.prefix}-wapp-${var.env}"
    container_port   = 80
  }

  depends_on = [
    aws_ecs_service.api,
    aws_service_discovery_service.api
  ]
}

# Define output information

output "app_lb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "App LB DNS Name"
}
