# **Windows Golden AMI Pipeline**
This lab will demonstrate creating a Windows AMI Pipeline using AWS Systems Manager (SSM) Automation. Most of this lab will be copying and pasting blocks of YAML code and explaining what each block does, a copy of the entire document will be included in step #7, if you would like to fast forward. In the end we will import the document to SSM Automation and fire it off to see what happens. This will help to drive the concepts of SSM Automation, and allow you to get comfortable building your own SSM Automation Worklflows. While this lab will focus on the AMI Pipeline use case, there are many other use cases and scenarios for SSM Automation.  

The pipeline we will build will do the following: 

1. Get Current AMI ID
2. Launch Current AMI
3. Install any Windows OS Updates
4. Update any AWS Agent Components
5. Install Additional Software
6. Sysprep Image
7. Create New Windows AMI

## Lab Pre-Reqs

[**Click here To Deploy Lab Pre-Reqs into your Account**](https://console.aws.amazon.com/cloudformation/home#/stacks/new?region=us-east-1&stackName=PsDscSSMLab&templateURL=https://alpublic.s3.amazonaws.com/ssmlabprereq.yml)

This CloudFormation Template will deploy the following resources:

* S3 Bucket to store files
* IAM Instance Role that allows Instances to use the AWS Systems Manager Service

Please examine the the cloudformation template below in the resources section. Once deployed go to the Output section and note the LabBucketName and InstanceProfile, we will need this info for later steps. 

You will need a text or code editor of choice installed on the machine you will be using for this lab. Please ensure that the text\code editor can do syntax highlighting for YAML as that is the language we will be using in this lab. AWS Systems Manager Automation also supports JSON format. 

## Set Automation Document Scaffolding 

Create a new text file and call it WindowsAMIPipeline.yaml, and copy in the scaffolding from the next code block. This represents the beginning of our Automation document. A Systems Manager Automation document defines the actions that Systems Manager performs on your managed instances and AWS resources. Documents use JavaScript Object Notation (JSON) or YAML, and they include steps and parameters that you specify. Steps run in sequential order.

Automation documents are Systems Manager documents of type Automation, as opposed to Command documents. Automation documents currently support schema version 0.3. Command documents use schema version 1.2, 2.0, or 2.2. There are four sections that make up a Automation document, description (optional), schemaVersion (required), parameters (optional), mainSteps (required). 

```YAML
description: 'Sample Automation to Create a Windows AMI'
schemaVersion: '0.3'
parameters:
mainSteps:
```
## Adding in Parameters

Let's Add in some Parameters before we get started on our mainSteps section. Parameters in AWS Systems Manager Automation documents are used in a basic string replace. However, using parameters allows us to re-use Automation Documents instead of building them for single-use. 

```YAML
description: 'Sample Automation to Create a Windows AMI'
schemaVersion: '0.3'
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
  OutputS3BucketName:
    type: String
    description: 'The S3 bucket to store logs and grab scripts.'
    default: 'samples-us-east-1'
mainSteps:
```
## mainSteps Section - where all the actions happens. 

Systems Manager Automation runs steps defined in Automation documents. Each step is associated with a particular action. The action determines the inputs, behavior, and outputs of the step. Steps are defined in the mainSteps section of your Automation document.

You don't need to specify the outputs of an action or step. The outputs are predetermined by the action associated with the step. When you specify step inputs in your Automation documents, you can reference one or more outputs from an earlier step. For example, you can make the output of aws:runInstances available for a subsequent aws:runCommand action. You can also reference outputs from earlier steps in the Output section of the Automation document. 


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
        - !Ref 'PsDscSSMLabRole'
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