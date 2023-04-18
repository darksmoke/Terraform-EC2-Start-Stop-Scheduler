import boto3
import json
import os

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    tag_filters = json.loads(os.environ['TAG_FILTERS'])

    filters = [{'Name': f"tag:{key}", 'Values': [value]} for key, value in tag_filters.items()]

    instances = ec2.describe_instances(Filters=filters)

    instance_ids = [
        instance["InstanceId"]
        for reservation in instances["Reservations"]
        for instance in reservation["Instances"]
    ]

    if event['detail']['state'] == 'ENABLED':
        ec2.start_instances(InstanceIds=instance_ids)
        print(f"Started instances: {', '.join(instance_ids)}")
    elif event['detail']['state'] == 'DISABLED':
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Stopped instances: {', '.join(instance_ids)}")
