# **Windows Golden AMI Pipeline**
This lab will demonstrate creating a Windows AMI Pipeline using AWS Systems Manager (SSM) Automation. Most of this lab will be copying and pasting blocks of YAML code and explaining what each block does, a copy of the entire document will be included in step #8, if you would like to fast forward. In the end we will import the document to SSM Automation and fire it off to see what happens. This will help to drive the concepts of SSM Automation, and allow you to get comfortable building your own SSM Automation Worklflows. While this lab will focus on the AMI Pipeline use case, there are many other use cases and scenarios for SSM Automation.  

The pipeline we will build will do the following: 

1. Get Current AMI ID
2. Launch Current AMI\ Tag Instances
3. Execute Scripts in Line
4. Execute Scripts from Remote Location
5. Update AWS Systems Manager Agent
6. Install any Windows OS Updates
7. Sysprep Image
8. Create New Windows AMI

## Lab Pre-Reqs

[**Click here To Deploy Lab Pre-Reqs into your Account**](https://console.aws.amazon.com/cloudformation/home#/stacks/new?region=us-east-1&stackName=PsDscSSMLab&templateURL=https://alpublic.s3.amazonaws.com/ssmlabprereq.yml)

This CloudFormation Template will deploy the following resources:

* S3 Bucket to store files
* IAM Instance Role that allows Instances to use the AWS Systems Manager Service

Please examine the the cloudformation template below in the resources section. Once deployed go to the Output section and note the LabBucketName and InstanceProfile, we will need this info for later steps. 

You will need a text or code editor of choice installed on the machine you will be using for this lab. Please ensure that the text\code editor can do syntax highlighting for YAML as that is the language we will be using in this lab. AWS Systems Manager Automation also supports JSON format. 

Also copy the powershell code below to a script called **RemoteS3.ps1** and upload it to the S3 Bucket created from the CloudFormation template. 
```PowerShell
Write-Host "Hello World!  This is an example script which was downloaded from S3 and then executed."
```

## Set Automation Document Scaffolding 

Create a new text file and call it WindowsAMIPipeline.yaml, and copy in the scaffolding from the next code block. This represents the beginning of our Automation document. A Systems Manager Automation document defines the actions that Systems Manager performs on your managed instances and AWS resources. Documents use JavaScript Object Notation (JSON) or YAML, and they include steps and parameters that you specify. Steps run in sequential order.

Automation documents are Systems Manager documents of type Automation, as opposed to Command documents. Automation documents currently support schema version 0.3. Command documents use schema version 1.2, 2.0, or 2.2. There are four sections that make up a Automation document, description (optional), schemaVersion (required), parameters (optional), mainSteps (required). 

```YAML
---
schemaVersion: "0.3"
description: 'Sample Automation to Create a Windows AMI'
parameters:
mainSteps:
```
## Adding in Parameters

Let's Add in some Parameters before we get started on our mainSteps section. Parameters in AWS Systems Manager Automation documents are used in a basic string replace. However, using parameters allows us to re-use Automation Documents instead of building them for single-use. 

```YAML
---
schemaVersion: "0.3"
description: 'Sample Automation to Create a Windows AMI'
parameters:
  SourceAmiId:
    type: String
    description: '(Required) SSM AMI Parameter.'
    default: /aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base
  IamInstanceProfileName:
    type: String
    description: '(Required) The name of the role that enables Systems Manager to manage the instance.'
    default: IAMInstanceProfile
  InstanceType:
    type: String
    description: '(Optional) Select the instance type.'
    default: m5.large
  SubnetId:
    type: String
    description: '(Optional) Specify the SubnetId if you want to launch into a specific subnet.'
    default: ''
  NewImageName:
    type: String
    description: '(Optional) The name of the new AMI that is created.'
    default: 'NewAMI_Created_On_{{global:DATE_TIME}}'
  NewImageDescription:
    type: String
    description: '(Optional) The description of the new AMI that is created.'
    default: 'NewAMI_Created_On_{{global:DATE}}'
  S3BucketName:
    type: String
    description: 'The S3 bucket to store logs and grab scripts.'
    default: 'LabBucketName'
mainSteps:
```
## mainSteps Section - where all the actions happens. 

Systems Manager Automation runs steps defined in Automation documents. Each step is associated with a particular action. The action determines the inputs, behavior, and outputs of the step. Steps are defined in the mainSteps section of your Automation document.

You don't need to specify the outputs of an action or step. The outputs are predetermined by the action associated with the step. When you specify step inputs in your Automation documents, you can reference one or more outputs from an earlier step. For example, you can make the output of aws:runInstances available for a subsequent aws:runCommand action. You can also reference outputs from earlier steps in the Output section of the Automation document. 

**Note:** All of the subsequent code blocks you will need to copy and paste after the mainSteps section of our Automation Document. 

### Step 1 - Get Latest Ami

Each step has required properties that need to be defined, here we are highlighting the properties that are required. For a full list of common properties check [AWS Systems Manager Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-actions.html#automation-common):

* name
  - An identifier that **__must be unique__** across all step names in the document and is required
* action
  - The name of the action the step is to run. aws:runCommand is an example of an action you can specify here. We will demonstrate several action types in this lab. 
* input
  - The properties specific to the action.

As we go along we will note and highlight any additional properties, and a brief explaination of the actions we are using. For a full list of [AWS Systems Manager Automation Actions](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-actions.html)please reference the SSM Documentation. 

In this first step we are grabbing the latest AMI ID from SSM Parameter store and outputting its value for subsquent steps. SSM Automation has [system variables](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-variables.html), SSM parameters being one of the system variables that can be used in a step definition. However, there are supported cases and unsupported cases and using SSM Parameters in the input of a action is an unsupported case. To work around this we use the [***aws:executeAwsApi***](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-actions.html#automation-action-executeAwsApi) action. 

***aws:executeAwsApi*** action calls and runs AWS API actions. Most API actions are supported, although not all API actions have been tested. For more information and examples of how to use this action, see [Invoking Other AWS Services from a Systems Manager Automation Workflow](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-aws-apis-calling.html).

As with many API Calls we get a response that we need to parse, to do that with SSM Automation we need to use [JSONPath](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-aws-apis-calling.html#automation-aws-apis-calling-json-path) to pull a specific value from a response. In the output section under Selector, you can see the JSONPath being used to grab the Latest AMI ID from the response of our GetParameter API call to SSM.  

```YAML
  # Optional Step: This step will grab the latest AMI ID using SSM Parameter Store  
  # Doing this we can alway start with the latest AWS AMI and add our needed components. 
  - name: "GetLatestAmi"
    action: aws:executeAwsApi
    inputs:
      Service: ssm
      Api: GetParameter
      Name: '{{ SourceAmiId }}'
    outputs:
      - Name: AMI
        Selector: "$.Parameter.Value"
        Type: "String"
```

### Step 2 - Launch Instance and Tag

In this step we will launch an instance from the AMI ID that we grabbed in the previous step. To do this we will use the [***aws:runInstances***](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-actions.html#automation-action-runinstance) action. The action supports most API parameters of the [RunInstances](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html) API. 

Not pointed out in our previous step is how the variables are being used in each step. If we look at the input parameters of the ***aws:runInstances*** action there are variables surrounded by double curly braces and in quotes, notice values for ImageId, InstanceType, IamInstanceProfileName and SubnetId. In the ImageId section we are referencing the output of the GetLatestAmi Step, in the other parameters we are passing in the parameters we defined at the beginning of the document. 

In these steps we have also defined the ***timeoutSeconds*** property which is being used in conjunction with the ***maxAttempts*** property. If the timeout is reached and the value of maxAttempts is greater than 1, then the step is not considered to have timed out until all retries have been attempted. There is no default value for this field. maxAttempts is the number of times the step should be retried in case of failure. If the value is greater than 1, the step is not considered to have failed until all retry attempts have failed. The default value is 1.

Finally in these two steps we are also using the ***onFailure*** property which indicates whether the workflow should abort, continue,or go to a different step on failure. If you were to specify a step the format would be ***step:step_name***. The default value for this option is abort. The tag step also demontrates use of another system variable in the tag value, you see we are appending the automation execuion ID to the tag using ***{{automation:EXECUTION_ID}}***. 

```YAML
  # Required Step: This step will launch an instance from the source AMI that you specified.  
  # This step will return the instance id of the instance that was launched.
  - name: LaunchInstance
    action: 'aws:runInstances'
    timeoutSeconds: 1800
    maxAttempts: 3
    onFailure: Abort
    inputs:
      ImageId: '{{ GetLatestAmi.AMI }}'
      InstanceType: '{{ InstanceType }}'
      MinInstanceCount: 1
      MaxInstanceCount: 1
      IamInstanceProfileName: '{{ IamInstanceProfileName }}'
      SubnetId: '{{ SubnetId }}'
  # Optional Step: This step will tag your instance. Why do this? 
  # Helps make it clear which instance is being used to create this AMI.
  - name: TagInstance
    action: 'aws:createTags'
    maxAttempts: 3
    onFailure: Abort
    inputs:
      ResourceType: EC2
      ResourceIds: '{{ LaunchInstance.InstanceIds }}'
      Tags:
        - Key: "Name"
          Value: "GoldenAMI__{{automation:EXECUTION_ID}}"
```
### Step 3 - Using Run Command to Execute Scripts in line

Now on to the meat and potatoes, once we have an instance that has been launched and registered to AWS Systems Manager we can use the ***aws:runCommand*** action which will execute scripts and code on our instance. This action will most likely be the most used action in your automation workflows for Windows workloads. We can use this action to install software or configure the AMI to meet internal corporate standards. 

In this Step we are executing the **AWS-RunPowerShellScript** command document. This will give us access to PowerShell to run cmdlets and or script within the instance. In order to do this we need to provide an instance to the Command Document, notice how the instance ID is being grabbed from the LaunchInstance Step. You will also notice here we are outputing the result of the script to S3 so we can review the logs. In this step we are simply writing out the OS version to the console, which will appear in our S3 Log Output. 

```YAML
  # Optional Step: This step shows you how to execute a script on the instance where the script code is inline to this document.
  - name: ExampleInlineScript
    action: 'aws:runCommand'
    timeoutSeconds: 60
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/ExampleInlineScript/"
      DocumentName: AWS-RunPowerShellScript
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        executionTimeout: '7200'
        commands:
          - |
             $version = [System.Environment]::OSVersion.Version
             Write-Host "$($version.ToString())"
```
### Step 4 - Using Run Command to Execute Scripts from a Remote Location

In this step we are again using the ***aws:runCommand*** action but using the **AWS-RunRemoteScript** document. This document will download a script from S3 or Github and execute them on the target instance. We can use these scripts to do custom configuration on the instance or install software. Also note that in this step we are not outputting logs to S3 but instead outputting them to CloudWatch Logs. 

 ```YAML
  # Optional Step: This step shows you how to execute a powershell script that is located in S3.
  - name: ExampleS3Script
    action: 'aws:runCommand'
    timeoutSeconds: 60
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      CloudWatchOutputConfig:
        CloudWatchOutputEnabled: "true"
        CloudWatchLogGroupName: '/GoldenAMILogs/{{automation:EXECUTION_ID}}/ExampleS3Script'
      DocumentName: AWS-RunRemoteScript
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        executionTimeout: '60'
        sourceType: "S3"
        commandLine: "./RemoteS3.ps1"
        sourceInfo: '{"path": "https://{{S3BucketName}}.s3.amazonaws.com/RemoteS3.ps1"}'
```
### Step 5 - Updating SSM Agent

Again we are using the ***aws:runCommand*** action but this time using the **AWS-UpdateSSMAgent**, this will install the latest version of the SSM agent into the instance that will eventually become our AMI. 

```YAML
  # Recommended Step: This step will update the SSM Agent on your instance.
  - name: UpdateSSMAgent
    action: 'aws:runCommand'
    timeoutSeconds: 14400
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/UpdateSSMAgent/"
      DocumentName: AWS-UpdateSSMAgent
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        allowDowngrade: 'false'
```

### Step 6 - Install any Windows OS Updates

Again we are using the ***aws:runCommand*** action but this time using the **AWS-InstallWindowsUpdates**, this will install all available windows updates at the time of execution. We see that we have used several different AWS Managed Command Documents in our workflow for a complete list we can run the ***aws ssm list-documents*** cli command or peruse in via the AWS Systems Manager Web Console under Shared Resources --> Documents. For a list of [AWS Managed Automation Documents](https://docs.aws.amazon.com/systems-manager/latest/userguide/automation-documents-reference-details.html) you can reference SSM Documentation. You can also call another Automation Document using the ***aws:executeAutomation*** action. 

```YAML
  # Recommended Step: This step will install all available Windows updates that are available at the time of execution.
  - name: InstallWindowsUpdates
    action: 'aws:runCommand'
    timeoutSeconds: 14400
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/InstallWindowsUpdates/"
      DocumentName: AWS-InstallWindowsUpdates
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        Action: Install
```

### Step 7 - Sysprep Image\Stop Instance

We are using the ***aws:runCommand*** action one last time to run the **AWSEC2-RunSysprep** document that will generalize our Instance so we can convert it an AMI. We then are running the ***aws:changeInstanceState** action which will stop our EC2 Instance so we can convert it to an AMI. 

```YAML
  # Required Step: This step will perform sysprep on your instance using the recommended approach from AWS by using the public run command document AWSEC2-RunSysprep.
  - name: RunSysprepGeneralize
    action: 'aws:runCommand'
    timeoutSeconds: 600
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/RunSysprepGeneralize/"
      DocumentName: AWSEC2-RunSysprep
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        Id: '{{automation:EXECUTION_ID}}'
  # Required Step: The instance should be in the stopped state prior to creating your image and this step will stop your instance.  This previous sysprep step does not shutdown the OS.
  - name: StopInstance
    action: 'aws:changeInstanceState'
    timeoutSeconds: 7200
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      CheckStateOnly: false
      DesiredState: stopped
```
### Step 8 - Create New Windows AMI\Terminate Instance

Now we are in the home stretch, we will use the ***aws:createImage*** action to create a new AMI. Once that is completed we will use the ***aws:changedInstanceState*** action to terminate the instance since we no longer need it. You will notice that in the last step we are using the ***isEnd*** option, this option stops an Automation execution at the end of a specific step. The Automation execution stops if the step execution failed or succeeded. The default value is false and is optional to use. 

```YAML
  # Required Step:  This step will create a new image from the stopped instance.  It will return the new AMI id.
  - name: CreateImage
    action: 'aws:createImage'
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      ImageName: '{{ NewImageName }}'
      ImageDescription: '{{ NewImageDescription }}'
      InstanceId: '{{ LaunchInstance.InstanceIds }}'
      NoReboot: true
  # Recommended Step: This step will terminiate the instance that was used to create your new AMI.  AWS recommends terminiating it to free resources and saving you $.
  - name: TerminiateInstance
    action: 'aws:changeInstanceState'
    maxAttempts: 3
    onFailure: Abort
    isEnd: true
    inputs:
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      DesiredState: terminated
```
## Final SSM Automation Document - Create Automation Document

Once we have copied all sections in our final SSM Automation Document should look like the following code block. Please double check and make sure everything looks right.  
```YAML
---
schemaVersion: "0.3"
description: 'Sample Automation to Create a Windows AMI'
parameters:
  SourceAmiId:
    type: String
    description: '(Required) The source Amazon Machine Image ID.'
    default: /aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base
  IamInstanceProfileName:
    type: String
    description: '(Required) The name of the role that enables Systems Manager to manage the instance.'
    default: IAMInstanceProfile
  InstanceType:
    type: String
    description: '(Optional) Select the instance type.'
    default: m5.large
  SubnetId:
    type: String
    description: '(Optional) Specify the SubnetId if you want to launch into a specific subnet.'
    default: subnet-dc5f7884
  NewImageName:
    type: String
    description: '(Optional) The name of the new AMI that is created.'
    default: 'NewAMI_CreatedFrom_{{SourceAmiId}}_On_{{global:DATE_TIME}}'
  NewImageDescription:
    type: String
    description: '(Optional) The description of the new AMI that is created.'
    default: 'NewAMI_CreatedFrom_{{SourceAmiId}}_On_{{global:DATE}}'
  S3BucketName:
    type: String
    description: 'The S3 bucket to store logs.'
    default: 'samples-us-east-1'
mainSteps:
  # Optional Step: This step will grab the latest AMI ID using SSM Parameter Store  
  # Doing this we can alway start with the latest AWS AMI and add our needed components. 
  - name: "GetLatestAmi"
    action: aws:executeAwsApi
    inputs:
      Service: ssm
      Api: GetParameter
      Name: '{{ SourceAmiId }}'
    outputs:
      - Name: AMI
        Selector: "$.Parameter.Value"
        Type: "String"
  # Required Step: This step will launch an instance from the source AMI that you specified.  
  # This step will return the instance id of the instance that was launched.
  - name: LaunchInstance
    action: 'aws:runInstances'
    timeoutSeconds: 1800
    maxAttempts: 3
    onFailure: Abort
    inputs:
      ImageId: '{{ GetLatestAmi.AMI }}'
      InstanceType: '{{ InstanceType }}'
      MinInstanceCount: 1
      MaxInstanceCount: 1
      IamInstanceProfileName: '{{ IamInstanceProfileName }}'
      SubnetId: '{{ SubnetId }}'
  # Optional Step: This step will tag your instance. Why do this? 
  # Helps make it clear which instance is being used to create this AMI.
  - name: TagInstance
    action: 'aws:createTags'
    maxAttempts: 3
    onFailure: Abort
    inputs:
      ResourceType: EC2
      ResourceIds: '{{ LaunchInstance.InstanceIds }}'
      Tags:
        - Key: "Name"
          Value: "GoldenAMI__{{automation:EXECUTION_ID}}"
  # Optional Step: This step shows you how to execute a script on the instance where the script code is inline to this document.
  - name: ExampleInlineScript
    action: 'aws:runCommand'
    timeoutSeconds: 60
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/ExampleInlineScript/"
      DocumentName: AWS-RunPowerShellScript
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        executionTimeout: '7200'
        commands:
          - |
             $version = [System.Environment]::OSVersion.Version
             Write-Host "$($version.ToString())"
  # Optional Step: This step shows you how to execute a powershell script that is located in S3.
  - name: ExampleS3Script
    action: 'aws:runCommand'
    timeoutSeconds: 60
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      CloudWatchOutputConfig:
        CloudWatchOutputEnabled: "true"
        CloudWatchLogGroupName: '/GoldenAMILogs/{{automation:EXECUTION_ID}}/ExampleS3Script'
      DocumentName: AWS-RunRemoteScript
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        executionTimeout: '60'
        sourceType: "S3"
        commandLine: "./RemoteS3.ps1"
        sourceInfo: '{"path": "https://{{S3BucketName}}.s3.amazonaws.com/RemoteS3.ps1"}'
  # Recommended Step: This step will update the SSM Agent on your instance.
  - name: UpdateSSMAgent
    action: 'aws:runCommand'
    timeoutSeconds: 14400
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/UpdateSSMAgent/"
      DocumentName: AWS-UpdateSSMAgent
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        allowDowngrade: 'false'
  # Recommended Step: This step will install all available Windows updates that are available at the time of execution.
  - name: InstallWindowsUpdates
    action: 'aws:runCommand'
    timeoutSeconds: 14400
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/InstallWindowsUpdates/"
      DocumentName: AWS-InstallWindowsUpdates
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        Action: Install
  # Required Step: This step will perform sysprep on your instance using the recommended approach from AWS by using the public run command document AWSEC2-RunSysprep.
  - name: RunSysprepGeneralize
    action: 'aws:runCommand'
    timeoutSeconds: 600
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      OutputS3BucketName: "{{S3BucketName}}"
      OutputS3KeyPrefix: "GoldenAMILogs/{{automation:EXECUTION_ID}}/RunSysprepGeneralize/"
      DocumentName: AWSEC2-RunSysprep
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      Parameters:
        Id: '{{automation:EXECUTION_ID}}'
  # Required Step: The instance should be in the stopped state prior to creating your image and this step will stop your instance.  This previous sysprep step does not shutdown the OS.
  - name: StopInstance
    action: 'aws:changeInstanceState'
    timeoutSeconds: 7200
    maxAttempts: 3
    onFailure: step:TerminateInstance
    inputs:
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      CheckStateOnly: false
      DesiredState: stopped
  # Required Step:  This step will create a new image from the stopped instance.  It will return the new AMI id.
  - name: CreateImage
    action: 'aws:createImage'
    maxAttempts: 3
    onFailure: Abort
    inputs:
      ImageName: '{{ NewImageName }}'
      ImageDescription: '{{ NewImageDescription }}'
      InstanceId: '{{ LaunchInstance.InstanceIds }}'
      NoReboot: true
  # Recommended Step: This step will terminiate the instance that was used to create your new AMI.  AWS recommends terminiating it to free resources and saving you $.
  - name: TerminateInstance
    action: 'aws:changeInstanceState'
    maxAttempts: 3
    onFailure: Abort
    isEnd: true
    inputs:
      InstanceIds: '{{ LaunchInstance.InstanceIds }}'
      DesiredState: terminated
```
Save it to a file named WindowsAMIPipeline.yaml and note the location. You can use the AWS Cli to create the document using the command in the next code block. 

```
aws ssm create-document --content "file://PathtoFile/WindowsAMIPipeline.yaml" --name "WinWorkshopAMIPipeline" --document-type "Automation" --document-format YAML
```
You can also create the document via the web console. First you will wanto navigate to the AWS Systems Manager Web Console. And the under Shared Resources, Click on Documents
![](/assets/images/SharedResources1.png)

Then Click on Create Document. 
![](/assets/images/createdocumentbutton.png)

Then name the document and select Document Type as Automation. 
![](/assets/images/CreateDocumentName.png)

Then select YAML in this case, and copy the content of the document into the code window, and click create document. 
![](/assets/images/DocumentContent.png)

## Execute Automation Document
Now that we have created the document and understand the steps, lets execute the document and see what happens. 

Under Actions and Changes, click on Automation
![](/assets/images/ActionsChangesAutomation.png)

Then click on Execute Automation. 
![](/assets/images/ExecuteAutomationButton.png)

Then lets Click on Owned by me and select our WinWorkshopAMIPipeline and click Next. 
![](/assets/images/SelectAutomationDocument.png)

We can pick simple execution which will run the document, or Manual Execution where we would need to manually execute the documemt step by step.
![](/assets/images/ExecuteAutomationChoice.png)

Finally lets enter the parameters, using the Iam Instance Profile Name and S3 Bucket from the Output of the Pre-Req CloudFormation and click Execute. 
![](/assets/images/EnterParameterinAutomation.png)

You can then step through or watch the execution proceed. Click into each one of the steps and explore the inputs, outputs etc. Go to the S3 Bucket and check the logs, go to CloudWatch Logs and check those logs. 
![](/assets/images/ExecutionProgress.png)


## Resources

**Lab Pre-Req CloudFormation Template**
```YAML
AWSTemplateFormatVersion: "2010-09-09"
Description:
 This is a Cloudformation that setups Lab Components for PowerShell DSC Lab
Resources:
  LabBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
  LogonMessageParam:
    Type: AWS::SSM::Parameter
    Properties: 
      Description: Logon Message for Interactive Logon
      Name: LogonMessage
      Type: String
      Value: "'This is a Test System.,Testing how to Set a Logon Message with.,PowerShell DSC and AWS Systems Manager.,Parameter Store'"
  SSMLabRole:
    Type: AWS::IAM::Role
    Properties:
      Policies:
        - PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                  - s3:GetObject
                Resource: 
                  - !Sub 'arn:aws:s3:::aws-ssm-${AWS::Region}/*'
                  - !Sub 'arn:aws:s3:::aws-windows-downloads-${AWS::Region}/*'
                  - !Sub 'arn:aws:s3:::amazon-ssm-${AWS::Region}/*'
                  - !Sub 'arn:aws:s3:::amazon-ssm-packages-${AWS::Region}/*'
                  - !Sub 'arn:aws:s3:::${AWS::Region}-birdwatcher-prod/*'
                  - !Sub 'arn:aws:s3:::patch-baseline-snapshot-${AWS::Region}/*'
                Effect: Allow
          PolicyName: ssm-custom-s3-policy
        - PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                  - ssm:GetParameter
                Resource: 
                  - !Sub 'arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter/${LogonMessageParam}'
                Effect: Allow
          PolicyName: ssm-param-policy
        - PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Action:
                  - s3:GetObject
                  - s3:PutObject
                  - s3:PutObjectAcl
                Resource: 
                  - !Sub 'arn:${AWS::Partition}:s3:::${LabBucket}/*'
                Effect: Allow
          PolicyName: ssm-mof-bucket-policy
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Principal:
            Service: ec2.amazonaws.com
          Action: sts:AssumeRole
      ManagedPolicyArns:
        - !Sub 'arn:${AWS::Partition}:iam::aws:policy/AmazonSSMManagedInstanceCore'
        - !Sub 'arn:${AWS::Partition}:iam::aws:policy/CloudWatchAgentServerPolicy'
  SSMLabProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Roles:
        - !Ref 'SSMLabRole'
      Path: /
Outputs:
  LabBucketName:
    Description: S3 Bucket where MOF File will be uploaded to.
    Value: !Ref LabBucket
  InstanceProfile:
    Value: !Ref SSMLabProfile
  InstanceRoleArn:
    Value: !GetAtt SSMLabRole.Arn
  InstanceRoleName:
    Value: !Ref SSMLabRole
```