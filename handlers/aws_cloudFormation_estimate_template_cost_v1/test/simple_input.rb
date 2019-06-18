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
    'template_url' => 'https://s3-us-west-1.amazonaws.com/cloudformation-templates-us-west-1/Rails_Multi_AZ.template',
    'template_parameters' => '{"KeyName":"KineticDemoAWSWest","MultiAZDatabase":"true","SSHLocation":"0.0.0.0/0","WebServerCapacity":"2","DBAllocatedStorage":"5","DBInstanceClass":"db.m1.large","DBName":"myDatabase","DBPassword":"KineticDemo123","DBUser":"kineticdemo","InstanceType":"t2.small"}'
    }
}
