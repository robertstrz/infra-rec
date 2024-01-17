locals {
  container_name = "ecs-backend"
  container_port = 8080
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-integrated-${terraform.workspace}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 80
      }
    }
  }

  services = {
    ecs_demo_api = {
      cpu    = 1024
      memory = 1024

      # Container definition(s)
      container_definitions = {
        execution_role_arn = "role that has ecr access"
        (local.container_name) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "public.ecr.aws/aws-containers/ecs_api:1.0.0" // maybe tag from variable ?
          port_mappings = [
            {
              name          = local.container_name
              containerPort = local.container_port
              protocol      = "tcp"
            }
          ]
          environment = [{
            name  = "DB_PASSWORD"
            value = var.db_password
          }, {
            name  = "DB_HOST"
            value = aws_db_instance.app_db.address
          }, {
            name  = "DB_USER"
            value = aws_db_instance.app_db.username
          }, {
            name  = "DB_PORT"
            value = aws_db_instance.app_db.port
          }]
          security_groups = [aws_security_group.ecs_tasks_sg.id]
          enable_cloudwatch_logging = true
        }
      }

      service_connect_configuration = {
        namespace = "${var.app_name}-${terraform.workspace}"
        service = {
          client_alias = {
            port     = local.container_port
            dns_name = local.container_name
          }
          port_name      = local.container_port
          discovery_name = local.container_name
        }
      }

      load_balancer = {
        service = {
          target_group_arn = aws_lb_target_group.ecs_tg.arn
          container_name   = local.container_name
          container_port   = local.container_port
        }
      }

      subnet_ids = [aws_subnet.public_subnet, "subnet-bcde012a", "subnet-fghi345a"]
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = local.container_port
          to_port                  = local.container_port
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = aws_security_group.alb_sg.id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name = "ecs_tasks_sg-${terraform.workspace}"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["75.2.60.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# VPC, ALB, ACM, and other resources would be defined similarly...
# ... This code is for illustrative purposes and does not include all required elements.