import boto3
import os
import json

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_tags = json.loads(os.environ['INSTANCE_TAGS'])

    filters = [{'Name': f'tag:{k}', 'Values': [v]} for k, v in instance_tags.items()]

    if event['source'] == 'aws.events':
        if event['resources'][0].endswith('start_instances'):
            action = 'start'
        elif event['resources'][0].endswith('stop_instances'):
            action = 'stop'

        instances = ec2.describe_instances(Filters=filters)['Reservations']
        instance_ids = [i['Instances'][0]['InstanceId'] for i in instances]

        if action == 'start':
            ec2.start_instances(InstanceIds=instance_ids)
        elif action == 'stop':
            ec2.stop_instances(InstanceIds=instance_ids)
