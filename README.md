Assumptions:
- AWS Networking is in place
- there is some CI/CD that deploys image to ECR


Improvements:
- backend port as variable
- provide password for db from SSM/PM
- setup auto-deploy to ECS once new image is pushed to ECR
- setup aws api gateway for handling requests to backend
   - validating JWT
   - rate limiting
   - caching
- some helper function not to repeat constantly this type of code:
```
 ${var.app_name}-ecs-target-group-${terraform.workspace}
```

Missing:
- execution role