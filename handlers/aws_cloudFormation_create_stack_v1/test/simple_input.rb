{
  'info' =>
  {
    'access_key' => '',
    'secret_key' => '',
    'region' => 'us-west-2',
    'enable_debug_logging' => 'Yes'
  },
  'parameters' =>
  {
    'template_url' => 'https://s3-us-west-1.amazonaws.com/cloudformation-templates-us-west-1/DEVLAMP_Multi_AZ.template',
    'templateParameters' => '{"KeyName":"DevDemoAWSWest","VpcId":"vpc-6b727c0f","Subnets":"subnet-f0d319786","MultiAZDatabase":"true","SSHLocation":"0.0.0.0/0","WebServerCapacity":"2","DBAllocatedStorage":"5","DBInstanceClass":"db.m1.large","DBName":"myDatabase","DBPassword":"DevDemo123","DBUser":"kineticdemo","InstanceType":"t2.small"}',
    'stack_name' => 'devopsTestLampStack',
    }
}
