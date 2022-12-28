import boto3
import time

# ---------SETTINGS----------------
image_id = 'ami-08c40ec9ead489470'  # ubuntu 22.04
key_name = 'vockey'
instance_type = 't2.micro'

# ----------SCRIPT-----------------
ec2_client = boto3.client("ec2")
ec2_resource = boto3.resource("ec2")
elbv2_client = boto3.client('elbv2')

with open('master/init.sh', 'r') as file:
    instance_init_script = file.read()

# init master instance
instances_cluster = ec2_client.run_instances(
    ImageId=image_id,
    MinCount=1,
    MaxCount=1,
    InstanceType=instance_type,
    KeyName=key_name,
    UserData=instance_init_script
)

# Get the IDs of the instances that were launched
instance_ids = [{'Id': instance['InstanceId']} for instance in instances_cluster['Instances']]
print(f'Launched instances: {instance_ids}')

# Waiting for all instances to get into "running" state
print('Waiting for master instance to get into running state...')
running_instances_count = 0
master_ip = ''
while running_instances_count < 1:
    running_instances_count = 0
    private_ips = []
    for target in instance_ids:
        instance_resource = ec2_resource.Instance(target['Id'])
        if instance_resource.state['Name'] == 'running':
            master_ip = instance_resource.private_ip_address
            running_instances_count += 1
    time.sleep(2)

print('Hooray, master instance is running!')
print(master_ip)

with open('slave/init.sh', 'r') as file:
    instance_init_script = file.read()
# init slave instances
instances_cluster = ec2_client.run_instances(
    ImageId=image_id,
    MinCount=3,
    MaxCount=3,
    InstanceType=instance_type,
    KeyName=key_name,
    UserData=instance_init_script.replace('$MASTER_HOST', master_ip)
)