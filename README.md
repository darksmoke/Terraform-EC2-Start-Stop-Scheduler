# Terraform EC2 Start-Stop Scheduler

This Terraform module creates a Lambda function and schedules it with EventBridge to start and stop EC2 instances based on provided tags and cron expressions.

## Usage

```
module "ec2_start_stop_scheduler" {
    source         = "git::github.com/darksmoke/Terraform-EC2-Start-Stop-Scheduler?ref=main"
    region         = "us-west-2"
    instance_tags  = { "Environment" = "dev" }
    schedule_start = "cron(0 6 * * ? *)"
    schedule_stop  = "cron(0 18 * * ? *)"
}
```


## Variables

- `region` - AWS region (default: "us-west-2").
- `instance_tags` - Tags for the EC2 instances to be started and stopped (default: {}).
- `schedule_start` - Cron expression for the start of the EC2 instances (default: "cron(0 0 * * ? *)").
- `schedule_stop` - Cron expression for the stopping of the EC2 instances (default: "cron(0 12 * * ? *)").

## Outputs

- `lambda_function` - The created Lambda function.
