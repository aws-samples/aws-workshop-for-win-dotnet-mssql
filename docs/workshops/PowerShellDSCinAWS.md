# **Managing Windows Workloads at Scale with PowerShell DSC and AWS Systems Manager**
This lab will demonstrate one way to use PowerShell Desired State Configuration with AWS Systems Manager (SSM) to configure Windows workloads and maintain compliance. It's goal is to share a pattern and concepts that you can utilize within your own AWS Environment. In this lab we will do the following:

1. Generate a MOF File
2. Create an AWS Systems Manager Association
3. Use AWS Systems Manager Parameter Store
    * To provide Config Data to our MOF Configuration
    * To provide latest AMI IDs to deploy instances with CloudFormation and CLI
4. Verify the configuration of our EC2 Instances
5. Check and update complaince information

## Step 1 - Deploy Lab Pre-Req Components
[**Click here To Deploy Lab into your Account**](https://console.aws.amazon.com/cloudformation/home#/stacks/new?region=us-east-1&stackName=PsDscSSMLab&templateURL=https://alpublic.s3.amazonaws.com/psdsclabprereq.yml)

This CloudFormation Template will deploy the following resources:

* S3 Bucket to store MOF Files
* SSM Parameter for Logon Message
* IAM Instance Role that allows Instances to use the AWS Systems Manager Service

Please examine the the cloudformation template below. Once deployed go to the Output section and note the MofBucketName and InstanceProfile, we will need this info for later steps. 
```YAML
AWSTemplateFormatVersion: "2010-09-09"
Description:
 This is a Cloudformation that setups Lab Components for PowerShell DSC Lab
Resources:
  MofBucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
  LogonMessageParam:
    Type: AWS::SSM::Parameter
    Properties: 
      Description: Logon Message for Interactive Logon
      Name: LogonMessage
      Type: String
      Value: "'This is a Test System.,Testing how to Set a Logon Message with.,PowerShell DSC and AWS Systems Manager.,Parameter Store'"
  PsDscSSMLabRole:
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
                  - !Sub 'arn:${AWS::Partition}:s3:::${MofBucket}/*'
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
  PsDscSSMLabProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Roles:
        - !Ref 'PsDscSSMLabRole'
      Path: /
Outputs:
  MofBucketName:
    Description: S3 Bucket where MOF File will be uploaded to.
    Value: !Ref MofBucket
  InstanceProfile:
    Value: !Ref PsDscSSMLabProfile
  InstanceRoleArn:
    Value: !GetAtt PsDscSSMLabRole.Arn
  InstanceRoleName:
    Value: !Ref PsDscSSMLabRole
```

## Step 2 - Create Powershell Script that generates MOF Files
Copy the script below and run it on your local machine. This will generate a MOF File in ***C:\MofFiles*** directory and is named localhost.mof, we will rename it to winworkshop.mof. This MOF File will configure the following items:

* Sets the Interative Logon Message
* Installs IIS Web Services

Before running the script be sure to install the DSC modules on the machine you execute the script. Below are the commands that will install these from the PowerShell Gallery. There are many DSC Resources that can be used to perform things like Domain Join, or ensure local administrator groups have specific AD Users or Groups. 
```powershell
Install-Module -Name PSDscResources
Install-Module -Name SecurityPolicyDsc
```

**Take Note** of the use of SSM Parameter Tokens ***{ssm:LogonMessage}*** in the script. In this lab we will be using the [AWS-ApplyDSCMofs](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state-manager-using-mof-file.html) command document. When using this command document we can use tokens in the MOF file to grab config data from AWS Systems Manager Parameter Store, information from Tags assigned to the instance or a combination of both. In this case we are pulling the Logon Message string from SSM Parameter Store. This script will grab the Logon Message text from the parameter deployed in the Cloudformation template. 
```PowerShell
[CmdletBinding()]
param()

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName="*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        },
        @{
            NodeName = 'localhost'
        }
    )
}
# PowerShell DSC Configuration Function
configuration ssmlab {
    # Importing DSC Resource used in the Configuration 
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName SecurityPolicyDsc
    
    Node 'localhost'{
        # Configures the Interactive Logon Message
        SecurityOption LogonMessage {
            Name = "LogonMessage"
            Interactive_logon_Message_title_for_users_attempting_to_log_on = 'Logon policy From SSM'
            Interactive_logon_Message_text_for_users_attempting_to_log_on = '{ssm:LogonMessage}'
        }
        # Installs IIS
        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }
    }
}
# Create the MOF File from the Configuration Function
ssmlab -OutputPath 'C:\MofFiles' -ConfigurationData $ConfigurationData
```
Rename the MOF File to winworkshop.mof and upload it to the S3 Bucket that was created by the CloudFormation template, the name you can find in the output section of cloudformation.

## Step 3 - Create a State Manager Association using AWS-ApplyDSCMofs Document
Now that we have our pre-reqs and our MOF File let's configure a State Manager Association. You can use the AWS-ApplyDSCMofs Document with Run Command or Automation. However, using it with state manager allows us to report on compliance regularly and allows us to automatically pick up and configure new instances to our desired state. 

Here we are demonstrating State Manager Association creation via the web console, but this can be done via SDK, CLI or CloudFormation. We will only be focusing on the parameters we will we be changing, or important to note when setting up an association for this document. 

1. First Let's navigate to the AWS Systems Manager Web Console, and Click on State Manager on the left side of the web page under Nodes and Instances. 
  ![](/assets/images/StateManager1.png)
2. Once we are in the State Manager Console, we click on the Create Association Button
  ![](/assets/images/createassociationstart2.png)
3. We want to name the Association as well as select the AWS-ApplyDSCMof Document. 
  ![](/assets/images/associationnametarget3.png)
4. We want to point the document to the location of our MOF Files, this can be a file location, HTTP Location or S3 Bucket. In this example we are going to use the MOF File we uploaded to our S3 Bucket. ***Note*** the way we are specifying the S3 Bucket, this naming style if unique to this document. 
  ![](/assets/images/moflocation4.png)
Take notice of the ***MOF Operation mode**, here we are leaving it to apply which will apply configuration if our instance does not match the desired state. This can also be set to Report Only, which will not apply configuration but only report when an instance has drifted from a desired state. 
5. Next we will review the PS Gallery Setting and the Reboot Behavior. With the PS Gallery parameter set to true, the AWS-ApplyDSCMof document will automatically install the DSC modules specified in our MOF File. This combines what would be multiple steps into one. The Reboot Behavor setting has three option, After Mof, Immediately or Never. Reboot will occur if it is required for certain configurations such as joining a Domain. After MOF will apply all configurations in the MOF and the Reboot, Immediately will perform the reboot after applying the config that requires it, and Never will surpress reboot completely. 
  ![](/assets/images/PSGallery5.png)
6. Under Compliance Type we are going to create a Custom Compliance Type for this association. Targets are the instances we want to target with this association. We can manually select instances, select all instances managed in this region, or select by tag. In this case we want to target a specific Tag with the Name ***Build*** and the value of ***Base***. In a subsquent step we will be deploying instance with these tag values and ensuring they meet our configuration. 
  ![](/assets/images/associationtarget6.png)
7. Now lets specify a schedule we want the Association to evaluate compliance. Since we are doing this during a workshop, lets set this to 30 Minutes. The compliance severity parameter controls what level we want the reflected for this association in the dashboard. 
  ![](/assets/images/associationcron7.png) 
8. Finally, we can specify an S3 Bucket to write all command output to S3, if we do not output in the console is truncated to 2500 characters. You can also leave this unchecked and click on Create Association. 
  ![](/assets/images/createassociation8.png) 

We will leave this association perculating and come back to it once we have deployed a few instances. 

## Step 4 - Deploy a Windows EC2 Instances
Let's test out what our MOF File and Association does. If you have the AWS Cli installed and configured you can copy the command below, other wise use the web console to launch an instance. In the command below substitute the ***InstanceProfile*** after **--iam-instance-profile** with the name in the output of PsDscSSMInstanceProfile in the CloudFormation we deployed in Step 1. 
If you deploy via the web console be sure to select the Instance Profile with PsDSC in the name from the drop down as demonstrated in the next screenshot. This will allow the instance to communicate with AWS Systems Manager service. 

![](/assets/images/instanceprofilewebconsole.png)

**Note** the use of the of AWS Systems Parameter Store in  the CLI command to get the latest AMI ID for Windows 2019. AWS Systems Manager provides these parameters so you can get the latest AMI IDs in every region. 

```
aws ec2 run-instances --image-id $(aws ssm get-parameters --names /aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base --query 'Parameters[0].[Value]' --output text) --count 1 --instance-type t3.large --iam-instance-profile InstanceProfile --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WinWorkShop},{Key=Build,Value=Base}]'
```
Once we have the Instance deployed lets go back to our Association in State Manager and click into it.

![](/assets/images/clickintoassociation.png)

Then click the resources tab, we can see that our instance was picked up by the association based on the Build tag.

![](/assets/images/ResourceAssociation.png)

Once the association applies successfully, let's click into Compliance. 

![](/assets/images/Compliance.png)

When the association first applies, it reports that the instance is non-compliant and the applies the configuration. 

![](/assets/images/noncompliant1st.png)

We will need to go back to the association, and click on Apply Association Now to run it manually before the next cron schedule. 

![](/assets/images/ApplyAssociationNow.png)

Once we do so and it completes we can go back to Compliance, and see that it is now reporting as compliant. 

![](/assets/images/Compliant.png)

Let's test this by RDPing to the Instance, we should see the following interactive message before we login. 

![](/assets/images/LogonMessage.png)

Then grab the IP or Public DNS Name of the instance and throw into a Web Browser and see the IIS Splash Screen. 

![](/assets/images/IISWebServer.png)

Here we demonstrated how we can Generate a MOF file, use it with AWS Systems Manager to configure instances and report on compliance. Next we will see how we can do this at scale with an auto-scaling group. 

## Step 5 - Let's Try an Auto-Scaling Group

[**Click here To Deploy a Windows Auto-Scaling Group into your Account**](https://console.aws.amazon.com/cloudformation/home#/stacks/new?region=us-east-1&stackName=PsDscSSMLab&templateURL=https://alpublic.s3.amazonaws.com/windows-autoscaling.yml)

**Note** the use of the of AWS Systems Parameter Store in the LatestAmiId Parameter and the Parameter type. You can use SSM Parameter Store integration with Cloudformation and not use AMI Mappings to get the latest AMI ID for Windows 2019. AWS Systems Manager provides these parameters so you can get the latest AMI IDs in every region. 

Please examine the the cloudformation template below. Once deployed test as you did in Step 5. 
```YAML
AWSTemplateFormatVersion: '2010-09-09'
Description: This Template Deploys a Simple Windows Auto-Scaling Group
Parameters:
  KeyPairName:
    Description: Public/private key pairs allow you to securely connect to your instance
      after it launches
    Type: AWS::EC2::KeyPair::KeyName
  LatestAmiId:
    Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
    Default: /aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base
  HostInstanceProfile:
    Description: Grab the String from the Output name PsDscSSMInstanceProfile
    Type: String
  NumberOfHosts:
    AllowedValues:
      - '1'
      - '2'
      - '3'
      - '4'
    Default: '2'
    Description: Enter the number of hosts to create
    Type: String
  PublicSubnet1ID:
    Description: ID of the public subnet 1 that you want to provision into (e.g., subnet-a0246dcd)
    Type: AWS::EC2::Subnet::Id
  PublicSubnet2ID:
    Description: ID of the public subnet 2 you want to provision into (e.g., subnet-e3246d8e)
    Type: AWS::EC2::Subnet::Id
  MyInstanceType:
    Description: Amazon EC2 instance type for the first Remote Desktop Gateway instance
    Type: String
    Default: t3.large
    AllowedValues:
      - t3.small
      - t3.medium
      - t3.large
      - m5.large
  RDPCIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$
    Description: Allowed CIDR Block for external access to the Deployed Instances
    Type: String
  VPCID:
    Description: ID of the VPC (e.g., vpc-0343606e)
    Type: AWS::EC2::VPC::Id
Rules:
  SubnetsInVPC:
    Assertions:
      - Assert: !EachMemberIn
          - !ValueOfAll
            - AWS::EC2::Subnet::Id
            - VpcId
          - !RefAll 'AWS::EC2::VPC::Id'
        AssertDescription: All subnets must in the VPC
Resources:
  WinAutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      LaunchConfigurationName: !Ref 'WinLaunchConfiguration'
      VPCZoneIdentifier:
        - !Ref 'PublicSubnet1ID'
        - !Ref 'PublicSubnet2ID'
      MinSize: !Ref 'NumberOfHosts'
      MaxSize: !Ref 'NumberOfHosts'
      Cooldown: '300'
      DesiredCapacity: !Ref 'NumberOfHosts'
      Tags:
        - Key: Name
          Value: WinWorkshop
          PropagateAtLaunch: 'true'
        - Key: Build
          Value: Base
          PropagateAtLaunch: 'true'
  WinLaunchConfiguration:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      ImageId: !Ref 'LatestAmiId'
      SecurityGroups:
        - !Ref 'WinWorkshopSG'
      IamInstanceProfile: !Ref 'HostInstanceProfile'
      InstanceType: !Ref 'MyInstanceType'
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: '50'
            VolumeType: gp2
      KeyName: !Ref 'KeyPairName'
  WinWorkshopSG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable RDP access from the Internet
      VpcId: !Ref 'VPCID'
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '3389'
          ToPort: '3389'
          CidrIp: !Ref 'RDPCIDR'
        - IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: !Ref 'RDPCIDR'
        - IpProtocol: tcp
          FromPort: '443'
          ToPort: '443'
          CidrIp: !Ref 'RDPCIDR'
```
Once the Auto-Scaling Group is deployed using CloudFormation, lets run through the same steps as in Step 4, to review and test our configuration. 

Using this method we can configure Windows Workloads at scale, using tags, SSM State Manager, SSM Parameter Store and PowerShell DSC. 

