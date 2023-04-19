import boto3
import os
import json

REGION = os.environ['AWS_REGION']
TAG_FILTERS = json.loads(os.environ['TAG_FILTERS'])

def get_instance_ids(ec2, state):
    filters = [{'Name': f'tag:{key}', 'Values': [value]} for key, value in TAG_FILTERS.items()]
    filters.append({'Name': 'instance-state-name', 'Values': [state]})

    print(f"Filters: {filters}")

    instance_ids = []
    paginator = ec2.get_paginator('describe_instances')

    for page in paginator.paginate(Filters=filters):
        print(f"Page: {page}")
        for reservation in page['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                instance_tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                print(f"Instance ID: {instance_id}, State: {state}, Tags: {instance_tags}")
                instance_ids.append(instance_id)

    return instance_ids



def start_instances(ec2):
    instance_ids = get_instance_ids(ec2, 'stopped')

    if instance_ids:
        print(f"Starting instances: {', '.join(instance_ids)}")
        ec2.start_instances(InstanceIds=instance_ids)
    else:
        print("No stopped instances found with the specified tag.")

def stop_instances(ec2):
    instance_ids = get_instance_ids(ec2, 'running')

    if instance_ids:
        print(f"Stopping instances: {', '.join(instance_ids)}")
        ec2.stop_instances(InstanceIds=instance_ids)
    else:
        print("No running instances found with the specified tag.")

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=REGION)

    print("Event:", event['resources'][0])
    print(event)

    if event['detail-type'] == "Scheduled Event":
        if "__start" in event['resources'][0]:
            print("== handler start ( ", event['resources'][0], " )")

            start_instances(ec2)
        elif "__stop" in event['resources'][0]:
            print("== handler stop")
            stop_instances(ec2)