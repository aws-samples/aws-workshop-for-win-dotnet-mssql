# Challenge 3: A Solution (unless you know a better one!)

## Testing the approach
Since Powershell Core Commandlets can run locally as well as in the Lambda execution environment, we can write and test the script before we deploy it to Lambda.

Our first task becomes identifying the EC2 instances that match our 'Production' tag. This can be accomplished using the `Get-EC2Instance` Commandlet. Let's test it out:

```
Get-EC2Instance -Filter @( @{name='tag:Purpose';value='Development'} )
```

*Example Results*
```
GroupNames    : {}
Groups        : {}
Instances     : {xxxx}
OwnerId       : 999999999999
RequesterId   : 
ReservationId : r-0011223344556677

GroupNames    : {}
Groups        : {}
Instances     : {yyyy}
OwnerId       : 999999999999
RequesterId   : 
ReservationId : r-0011223344556677

GroupNames    : {}
Groups        : {}
Instances     : {zzzz}
OwnerId       : 999999999999
RequesterId   : 
ReservationId : r-0011223344556677
```

## Defining Permissions

Once we know our command works, we can deploy it as a Lambda. But first, we need to define a set of permissions that grants the ability to list EC2 instances, as well as start and stop instances. This requires that we create a role with an attached policy. Ideally, we'd create two roles: one that has the ability to list & start EC2 instances and another with permission to list & stop instances, but for simplicity's sake we'll define it as a single policy and use it for both Lambdas. In the example below, we are defining a policy that grants access to write logs to CloudWatch, the ability to start and stop EC2 instances, and the ability to list EC2 instances:

*StartStopInstancesRole*
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LambdaLogging",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "StartStopInstances",
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*"
        },
        {
            "Sid": "DescribeInstances",
            "Effect": "Allow",
            "Action": "ec2:DescribeInstances",
            "Resource": "*"
        }
    ]
}
```
## Writing the scripts

Once we have our permissions defined, we need to create our Lambda functions. We will write two: one to list and stop instances, and another to list and stop instances. In order to make our Lambda more flexible, we will use an environment variable named 'PURPOSE' to supply the value of the "Purpose" tag we're filtering on. 

*StartInstances.ps1*
```
#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.390.0'}
$instances=Get-EC2Instance -Filter @( @{name='tag:Purpose';value="$env:PURPOSE_TAG"} ) | Select-Object -ExpandProperty RunningInstance
Write-Host "Stopping $($instances.Length) instances..."
Start-EC2Instance -InstanceId $instances
```

*StopInstances.ps1*
```
#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.390.0'}
$instances=Get-EC2Instance -Filter @( @{name='tag:Purpose';value="$env:PURPOSE_TAG"} )|Select-Object -ExpandProperty RunningInstance
Write-Host "Stopping $($instances.Length) instances..."
Stop-EC2Instance -InstanceId $instances
```

## Publishing the Lambda

Finally, we will publish our Lambdas:

```
Publish-AWSPowerShellLambda -ScriptPath ./StartInstances.ps1 -IAMRoleArn <Your role's name> -Name StartInstances -EnvironmentVariable @{"PURPOSE"="Development"}

Publish-AWSPowerShellLambda -ScriptPath ./StopInstances.ps1 -IAMRoleArn <Your role's name> -Name StopInstances -EnvironmentVariable @{"PURPOSE"="Development"}
```

## Scheduling our Lambdas

Now we need to schedule our Lambdas. To do this, we will need to create a CloudWatch Event rule that fires the event on a schedule. You can do this via the console or PowerShell using CloudWatch's support for Cron syntax:

```
Write-CWERule -Name StartOfDay -ScheduleExpression "cron(0 12 * * ? *)"
Write-CWERule -Name EndOfDay -ScheduleExpression "cron(0 21 * * ? *)"
```

Each of these will write an ARN for the new event to the console.
Next, we will need to grant permission for these new events to invoke our Lambda functions. For each of the Lambdas, we will need to grant the corresponding event permission:

```
Add-LMPermission -FunctionName <Lambda name> -StatementId MyStatement -Action 'lambda:InvokeFunction' -Principal events.amazonaws.com -SourceArn <your event ARN>
```

Finally, we need to associate the event with our Lambda by creating a target for the events, using the name of the rule and the ARN of the function. To get the ARN of your lambda, you can use the `Get-LMFunctionConfiguration` Cmdlet:

```
Get-LMFunctionConfiguration <Function name>
```

Now that we know the ARN, let's wire up the target:

```
Write-CWETarget -Rule <Rule name> -Target @{ ID=1;Arn ="<Lambda ARN>"}
```