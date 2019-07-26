title: Challenge 3: Create a Lambda Using PowerShell
# Challenge 3: Create a Lambda Using PowerShell

We have identified that our development staff tend to work between the hours of 8AM-6PM and do not work on weekends. We can save 70% on our compute costs by not paying to run these instances during off hours.

* Create a PowerShell-based Lambda function that stops EC2 instances that are tagged as "Purpose: Development"
* Create a PowerShell-based Lambda function that starts EC2 instances that are tagged as "Purpose: Development"
* Configure these Lambdas to be triggered at 6PM and 8AM M-F, respectively

Demonstrate your results using the Test feature of these lambdas to stop/start these instances.


## Solving the Problem

### Opening a PowerShell Core session
Let's open a PowerShell Core prompt; press and hold the Start button and press the 'R' key to open a "Run" dialog, type "Pwsh", and hit enter. This will open a PowerShell Core window.

In order to interact with AWS resources, we'll need to load the AWS PowerShell for .NET Core module as well as the AWS Tools for Powershell Lambda:

```
Install-Module AWSPowerShell.NetCore -Force
Install-Module AWSLambdaPSCore -Force
Import-Module AWSPowerShell.NetCore
Import-Module AWSLambdaPSCore
```

Next, let's make sure our commands will run in the correct region using the `Set-DefaultAWSRegion` commandlet:

```
Set-DefaultAWSRegion -Region us-east-1
```

### Designing and Testing Our Lambda
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

### Writing the scripts

Once we have our permissions defined, we need to create our Lambda functions. We will write two: one to list and stop instances, and another to list and stop instances. In order to make our Lambda more flexible, we will use an environment variable named 'PURPOSE' to supply the value of the "Purpose" tag we're filtering on. 

*StartInstances.ps1*
```
#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.390.0'}
$instances=Get-EC2Instance -Filter @( @{name='tag:Purpose';value="$env:PURPOSE_TAG"} ) | Select-Object -ExpandProperty RunningInstance
Write-Host "Starting $($instances.Length) instances..."
Start-EC2Instance -InstanceId $instances
```

*StopInstances.ps1*
```
#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.390.0'}
$instances=Get-EC2Instance -Filter @( @{name='tag:Purpose';value="$env:PURPOSE_TAG"} )|Select-Object -ExpandProperty RunningInstance
Write-Host "Stopping $($instances.Length) instances..."
Stop-EC2Instance -InstanceId $instances
```

### Publishing the Lambda

Finally, we will publish our Lambda's scripts, setting the `PURPOSE_TAG` environment variable's value to "Development":

```
Publish-AWSPowerShellLambda -ScriptPath ./StartInstances.ps1 -IAMRoleArn StartStopInstancesRole -Name StartInstances -EnvironmentVariable @{"PURPOSE_TAG"="Development"}

Publish-AWSPowerShellLambda -ScriptPath ./StopInstances.ps1 -IAMRoleArn StartStopInstancesRole -Name StopInstances -EnvironmentVariable @{"PURPOSE_TAG"="Development"}
```

### Scheduling our Lambdas

Now we need to schedule our Lambdas. To do this, we will need to create a CloudWatch Event rule that fires the event on a schedule. You can do this via PowerShell using CloudWatch's support for Cron syntax:

```
Write-CWERule -Name StartOfDay -ScheduleExpression "cron(0 12 * * ? *)"
Write-CWERule -Name EndOfDay -ScheduleExpression "cron(0 21 * * ? *)"
```

After the rule has been created, each of these commands will write an ARN for the new event to the console.
Next, we will need to grant permission for these new events to invoke our Lambda functions. For each of the Lambdas, we will need to grant the corresponding event permission:

```
Add-LMPermission -FunctionName StartInstances -StatementId MyStatement -Action 'lambda:InvokeFunction' -Principal events.amazonaws.com -SourceArn $(Get-CWERule StartOfDay -region us-east-1).Arn
Add-LMPermission -FunctionName StopInstances -StatementId MyStatement -Action 'lambda:InvokeFunction' -Principal events.amazonaws.com -SourceArn $(Get-CWERule EndOfDay -region us-east-1).Arn
```

Finally, we need to associate the event with our Lambda by creating a target for the events, using the name of the rule and the ARN of the function. To get the ARN of your lambda, you can use the `Get-LMFunctionConfiguration` Cmdlet:

```
Get-LMFunctionConfiguration <Function name>
```

Now that we know the ARN, let's wire up the target:

```
Write-CWETarget -Rule <Rule name> -Target @{ ID=1;Arn ="<Lambda ARN>"}
```

## Congratulations!

You have now created a Lambda that uses PowerShell Core to automate the management of your EC2 instances. We hope you now have a better understanding of what you can accomplish with PowerShell on AWS. Experiment with the available Commandlets to explore the options available to you (remember to adjust permissions!) or change the scheduling of function execution to suit your use case.

## References

* <a href="https://docs.aws.amazon.com/powershell/latest/userguide/pstools-using.html" target="_blank">Using the AWS Tools for Windows PowerShell</a>
* <a href="https://docs.aws.amazon.com/powershell/latest/reference/">AWS Tools for PowerShell Cmdlet Reference</a>
* <a href="https://docs.aws.amazon.com/powershell/latest/userguide/pstools-lambda.html" target="_blank">AWS Lambda and Tools for PowerShell</a>
* <a href="https://docs.aws.amazon.com/lambda/latest/dg/intro-permission-model.html">AWS Lambda Permissions Model</a>
* <a href="https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonec2.html">IAM Actions, Resources, and Condition Keys for Amazon EC2</a>
* <a href="https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/RunLambdaSchedule.html">Tutorial: Schedule AWS Lambda Functions Using CloudWatch Events</a>
