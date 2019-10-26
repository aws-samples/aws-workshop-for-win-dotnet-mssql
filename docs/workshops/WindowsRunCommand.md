# Using Run Command Against Windows Workloads
This lab will demonstrate how to use of the Run Commmand feature to run scripts against Windows Workloads. In this lab we will do the following:

1. Use the AWS-RunPowerShellScript Command Document to run PowerShell Cmdlets on our Instance
2. Use the AWS-RunRemoteScript Command Document to run a PowerShell script from an S3 Bucket to our Instance.

## Step 1 - Lab Pre-Req Components

### Create an EC2 Key Pair
Amazon EC2 uses public-key cryptography to encrypt and decrypt login information. Public-key cryptography uses a public key to encrypt a piece of data, such as a password, then the recipient uses the private key to decrypt the data. The public and private keys are known as a key pair. To log in to the Amazon instances we will create in this lab, you must create a key pair, specify the name of the key pair when you launch the instance, and provide the private key to get the login informtion for the Windows instance.

1. Use your administrator account to access the Amazon EC2 console at https://console.aws.amazon.com/ec2/.
2. In the IAM navigation pane under Network & Security, choose Key Pairs and then choose Create Key Pair.
3. In the Create Key Pair dialog box, type a Key pair name such as WinLab and then choose Create.
4. Save the keyPairName.pem file for optional later use accessing the EC2 instances created in this lab.

### Deploy Lab Pre-Reqs
[**Click here To Deploy Lab into your Account**](https://console.aws.amazon.com/cloudformation/home#/stacks/new?region=us-east-1&stackName=SSMLab&templateURL=https://alpublic.s3.amazonaws.com/ssmlabprereq-winec2inst.yml)

This CloudFormation Template will deploy the following resources:

* S3 Bucket to store MOF Files
* SSM Parameter for Logon Message
* IAM Instance Role that allows Instances to use the AWS Systems Manager Service
* Deploys a Single Windows Server 2019 t3.large EC2 Instance with an IAM Instance Profile allowing communication with AWS Systems Manager service. 

In the Parameters section do the following:

1. Leave LatestWindowsAmiId as the default, this will grab the latest AMI ID from AWS Systems Manager.
2. Select the EC2 KeyName you defined earlier from the list.
3. In a browser window, go to https://checkip.amazonaws.com/ to get your IP. Enter your IP address in SourceLocation in CIDR notation (i.e., ending in /32).
4. Choose Next.

Please examine the the cloudformation template below. Once deployed go to the Output section and note the information provided, we will need this info for later steps. 

**Note** the use of the of AWS Systems Parameter Store in the LatestWindowsAmiId Parameter and the Parameter type. You can use SSM Parameter Store integration with Cloudformation and not use AMI Mappings to get the latest AMI ID for Windows 2019. AWS Systems Manager provides these parameters so you can get the latest AMI IDs in every region. 

```YAML
---
AWSTemplateFormatVersion: "2010-09-09"
Description:
 This is a Cloudformation that setups Lab Components for Win SSM Lab
Parameters :
  LatestWindowsAmiId:
    # Use public Systems Manager Parameter
    Type : 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
    Default: '/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base'
  KeyPairName:
    Description: Public/private key pair, which allows you to securely connect to your instance
      after it launches.
    Type: AWS::EC2::KeyPair::KeyName
  SourceLocation:
      Description : The CIDR IP address range that can be used to RDP to the EC2 instances
      Type: String
      MinLength: 9
      MaxLength: 18
      Default: 0.0.0.0/0
      AllowedPattern: "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})"
      ConstraintDescription: must be a valid IP CIDR range of the form x.x.x.x/x.
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
                  - s3:ListBucket
                Resource: 
                  - !Sub 'arn:${AWS::Partition}:s3:::${LabBucket}/*'
                  - !Sub 'arn:${AWS::Partition}:s3:::${LabBucket}'
                Effect: Allow
          PolicyName: ssm-bucket-policy
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
  WinServerSG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Win Server Security Groups
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 3389
        ToPort: 3389
        CidrIp: !Ref SourceLocation
  WinServer:
    Type: "AWS::EC2::Instance"
    Properties:
      ImageId: !Ref LatestWindowsAmiId
      InstanceType: "t3.large"
      IamInstanceProfile: !Ref SSMLabProfile
      SecurityGroups: 
        - !Ref WinServerSG
      KeyName: !Ref 'KeyPairName'
      Tags:
      - Key: "Name"
        Value: "WinServer"
Outputs:
  WinServerPublic:
    Value: !GetAtt 'WinServer.PublicDnsName'
    Description: Public DNS for WinServer
  LabBucketName:
    Description: S3 Bucket where we will upload MOFs Files or PowerShell Code.
    Value: !Ref LabBucket
  InstanceProfile:
    Description: Instance Profile Name to Copy, when launching instances this will ensure the righ IAM rights.
    Value: !Ref SSMLabProfile
  InstanceRoleArn:
    Value: !GetAtt SSMLabRole.Arn
  InstanceRoleName:
    Value: !Ref SSMLabRole
```
### Create PowerShell Script in S3 Bucket
Copy the powershell code below to a script called **RemoteS3.ps1** and upload it to the S3 Bucket created from the CloudFormation template. 
```PowerShell
Write-Host "Hello World!  This is an example script which was downloaded from S3 and then executed."
```

## Step 2 - Run PowerShell Cmdlet with AWS-RunPowerShellScript Command Document
After we completed Step 1 we should have the following in our AWS Account:

* Windows Instance with a Tag of Name and Value of WinServer
* PowerShell Script Copied to the S3 Bucket Specified in Output of our Cloudformation Stack

Head over to the AWS Systems Manager Console, and ensure that we see our Instance showing up as a managed instances as shown in our next screenshot. 

![](/assets/images/managedinstance.png)

Now lets click on Run Command under Nodes & Instances. 

![](/assets/images/RunCommand.png)

Click on the Run Command Button in the upper right hand corner.

![](/assets/images/RunCommandButton.png)

Search for the **AWS-RunPowerShellScript** Command Document and Select it. 

![](/assets/images/AWS-RunPowerShellScriptSelect.png)

Copy the code from the next code block, and paste it into the command parameter box. This command will output the Windows OS Version and also give us a list of services on the box and their status. 

```
$version = [System.Environment]::OSVersion.Version
Write-Host "$($version.ToString())"
Get-Service
```
![](/assets/images/CommandInputRunPowerShell.png)

We need to determine how we are going to target our instances. In this case we are going to specify our targets by Tag which will pick up our deployed instance or any instance with that tag. 

![](/assets/images/RunCommandSpecifyTag.png)

In our next step we will specify how we want output logs to be handled. In this case we are going to output out Logs to S3 and also CloudWatch Logs. We will examine the output after we executed this run command document. 

![](/assets/images/RunCommandOutPutLogs.png)

Now that we have entered all the needed input, lets click on the ![Run Button](/assets/images/RunButton.png)

This will execute this command document against our target instances, we can monitoring the status after it is executed.

![](/assets/images/RunCommandExecuted.png)

Once completed we can click on the Instance ID, this will take us to the output portion. We can observe the output here of click to CloudWatch Logs or S3 to observe the logs there. 

![](/assets/images/CheckRunCommandOutput.png)

Here we demonstrated how we can use Run Command to run PowerShell Scripts and Commands on an instance and get the output information. Now lets see how we can use the AWS-RunRemoteScript command document to execute a powershell script from an S3 Bucket. 

## Step 3 - Run PowerShell Cmdlet with AWS-RunRemoteScript Command Document
We should still have the following setup in our AWS Account:

* Windows Instance with a Tag of Name and Value of WinServer
* PowerShell Script Copied to the S3 Bucket Specified in Output of our Cloudformation Stack

Head over to the AWS Systems Manager Console, and ensure that we see our Instance showing up as a managed instances as shown in our next screenshot. 
![](/assets/images/managedinstance.png)

Now lets click on Run Command under Nodes & Instances. 
![](/assets/images/RunCommand.png)

Click on the Run Command Button in the upper right hand corner. 
![](/assets/images/RunCommandButton.png)

Search for the **AWS-RunRemoteScript** Command Document and Select it. 
![](/assets/images/AWS-RunRemoteScriptSelect.png)

The command input for this document is different, we need to specify an S3 location and the command we wannt to run. 
![](/assets/images/RunRemoteCommandInput.png)

We need to determine how we are going to target our instances. In this case we are going to manually select our instance. 
![](/assets/images/RunCommandChooseManually.png)

In our next step we will specify how we want output logs to be handled. In this case we are going to output out Logs to S3 and also CloudWatch Logs. We will examine the output after we executed this run command document. 
![](/assets/images/RunCommandOutPutLogs.png)

Now that we have entered all the needed input, lets click on the ![Run Button](/assets/images/RunButton.png)

This will execute this command document against our target instances, we can monitoring the status after it is executed.
![](/assets/images/RunCommandExecuted.png)

Once completed we can click on the Instance ID, this will take us to the output portion. We can observe the output here of click to CloudWatch Logs or S3 to observe the logs there. 
![](/assets/images/CheckRunCommandOutput.png)

Here we demonstrated how we can use Run Command to run PowerShell Scripts from an S3 bucket, you can use this document to also pull code from a Github Repo.

## Review, Next Steps
In this lab we used Run Command to execute PowerShell Code on our EC2 Instance. 