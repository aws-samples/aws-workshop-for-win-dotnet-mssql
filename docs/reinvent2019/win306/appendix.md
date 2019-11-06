# Appendix - AWS CloudFormation Templates used to build Win306 Lab Environment

In order to provide another learning opportunity, wanted to provide all the CloudFormation Templates used to build out the lab environment. 

### Master Workshop Template
```YAML
AWSTemplateFormatVersion: '2010-09-09'
Description: WIN306 Setup
Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups:
      - Label:
          default: Source Network Configuration
        Parameters:
          - SrcAvailabilityZones
          - SrcVPCCIDR
          - SrcPrivateSubnet1CIDR
          - SrcPrivateSubnet2CIDR
          - SrcPublicSubnet1CIDR
          - SrcPublicSubnet2CIDR
      - Label:
          default: Destination Network Configuration
        Parameters:
          - DestAvailabilityZones
          - DestVPCCIDR
          - DestPrivateSubnet1CIDR
          - DestPrivateSubnet2CIDR
          - DestPublicSubnet1CIDR
          - DestPublicSubnet2CIDR
      - Label:
          default: Amazon EC2 Configuration
        Parameters:
          - RDGWInstanceType
      - Label:
          default: Microsoft Active Directory Configuration
        Parameters:
          - DomainDNSName
          - DomainNetBIOSName
          - DomainAdminPassword
          - ADEdition
      - Label:
          default: Microsoft Remote Desktop Gateway Configuration
        Parameters:
          - NumberOfRDGWHosts
          - RDGWCIDR
      - Label:
          default: AWS Quick Start Configuration
        Parameters:
          - QSS3BucketName
          - QSS3KeyPrefix
    ParameterLabels:
      AvailabilityZones:
        default: Availability Zones
      DomainAdminPassword:
        default: Domain Admin Password
      DomainDNSName:
        default: Domain DNS Name
      DomainNetBIOSName:
        default: Domain NetBIOS Name
      ADEdition:
        default: AWS Microsoft AD edition
      NumberOfRDGWHosts:
        default: Number of RDGW hosts
      PrivateSubnet1CIDR:
        default: Private Subnet 1 CIDR
      PrivateSubnet2CIDR:
        default: Private Subnet 2 CIDR
      PublicSubnet1CIDR:
        default: Public Subnet 1 CIDR
      PublicSubnet2CIDR:
        default: Public Subnet 2 CIDR
      QSS3BucketName:
        default: Quick Start S3 Bucket Name
      QSS3KeyPrefix:
        default: Quick Start S3 Key Prefix
      RDGWInstanceType:
        default: Remote Desktop Gateway Instance Type
      RDGWCIDR:
        default: Allowed Remote Desktop Gateway External Access CIDR
      VPCCIDR:
        default: VPC CIDR
Parameters:
  SrcAvailabilityZones:
    Description: 'List of Availability Zones to use for the subnets in the VPC. Note:
      The logical order is preserved and only 2 AZs are used for this deployment.'
    Default: 'eu-west-1a,eu-west-1b'
    Type: String
  DestAvailabilityZones:
    Description: 'List of Availability Zones to use for the subnets in the VPC. Note:
      The logical order is preserved and only 2 AZs are used for this deployment.'
    Default: 'eu-west-1a,eu-west-1b'
    Type: String
  DomainAdminPassword:
    AllowedPattern: (?=^.{6,255}$)((?=.*\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[^A-Za-z0-9])(?=.*[a-z])|(?=.*[^A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9]))^.*
    Default: Pass@word1
    Description: Password for the domain admin user. Must be at least 8 characters
      containing letters, numbers and symbols
    MaxLength: '32'
    MinLength: '8'
    NoEcho: 'true'
    Type: String
  DomainDNSName:
    AllowedPattern: '[a-zA-Z0-9\-]+\..+'
    Default: example.com
    Description: Fully qualified domain name (FQDN) of the forest root domain e.g.
      example.com
    MaxLength: '255'
    MinLength: '2'
    Type: String
  DomainNetBIOSName:
    AllowedPattern: '[a-zA-Z0-9\-]+'
    Default: example
    Description: NetBIOS name of the domain (up to 15 characters) for users of earlier
      versions of Windows e.g. EXAMPLE
    MaxLength: '15'
    MinLength: '1'
    Type: String
  ADEdition:
    AllowedValues:
      - Standard
      - Enterprise
    Default: Standard
    Description: The AWS Microsoft AD edition. Valid values include Standard and Enterprise.
    Type: String
  NumberOfRDGWHosts:
    AllowedValues:
      - '1'
      - '2'
      - '3'
      - '4'
    Default: '1'
    Description: Enter the number of Remote Desktop Gateway hosts to create
    Type: String
  SrcPrivateSubnet1CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 192.168.0.0/19
    Description: CIDR block for private subnet 1 located in Availability Zone 1.
    Type: String
  SrcPrivateSubnet2CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 192.168.32.0/19
    Description: CIDR block for private subnet 2 located in Availability Zone 2.
    Type: String
  SrcPublicSubnet1CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 192.168.128.0/20
    Description: CIDR Block for the public DMZ subnet 1 located in Availability Zone
      1
    Type: String
  SrcPublicSubnet2CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 192.168.144.0/20
    Description: CIDR Block for the public DMZ subnet 2 located in Availability Zone
      2
    Type: String
  DestPrivateSubnet1CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 10.0.0.0/19
    Description: CIDR block for private subnet 1 located in Availability Zone 1.
    Type: String
  DestPrivateSubnet2CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 10.0.32.0/19
    Description: CIDR block for private subnet 2 located in Availability Zone 2.
    Type: String
  DestPublicSubnet1CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 10.0.128.0/20
    Description: CIDR Block for the public DMZ subnet 1 located in Availability Zone
      1
    Type: String
  DestPublicSubnet2CIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 10.0.144.0/20
    Description: CIDR Block for the public DMZ subnet 2 located in Availability Zone
      2
    Type: String
  QSS3BucketName:
    AllowedPattern: ^[0-9a-zA-Z]+([0-9a-zA-Z-]*[0-9a-zA-Z])*$
    ConstraintDescription: Quick Start bucket name can include numbers, lowercase
      letters, uppercase letters, and hyphens (-). It cannot start or end with a hyphen
      (-).
    Default: alpublic
    Description: S3 bucket name for the Quick Start assets. Quick Start bucket name
      can include numbers, lowercase letters, uppercase letters, and hyphens (-).
      It cannot start or end with a hyphen (-).
    Type: String
  QSS3KeyPrefix:
    AllowedPattern: ^[0-9a-zA-Z-/]*$
    ConstraintDescription: Quick Start key prefix can include numbers, lowercase letters,
      uppercase letters, hyphens (-), and forward slash (/).
    Default: win306
    Description: S3 key prefix for the Quick Start assets. Quick Start key prefix
      can include numbers, lowercase letters, uppercase letters, hyphens (-), and
      forward slash (/).
    Type: String
  RDGWInstanceType:
    Description: Amazon EC2 instance type for the Remote Desktop Gateway instances
    Type: String
    Default: t2.large
    AllowedValues:
      - t2.large
      - m4.large
      - m4.xlarge
      - m4.2xlarge
      - m4.4xlarge
  RDGWCIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/x
    Default: 10.0.0.0/16
    Description: Allowed CIDR Block for external access to the Remote Desktop Gateways
    Type: String
  SrcVPCCIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 192.168.0.0/16
    Description: CIDR Block for the VPC
    Type: String
  DestVPCCIDR:
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(1[6-9]|2[0-8]))$
    ConstraintDescription: CIDR block parameter must be in the form x.x.x.x/16-28
    Default: 10.0.0.0/16
    Description: CIDR Block for the VPC
    Type: String
  LabType: 
    Description: 'Select your Database Migration lab:'
    Type: String
    Default: 'Microsoft SQL Server to Amazon RDS SQL Server'
  EC2ServerInstanceType:
    Description: Amazon EC2 Instance Type
    Type: String
    Default: m5.2xlarge
    AllowedValues:
      - m5.large
      - m5.xlarge
      - m5.2xlarge
      - m5.4xlarge
      - m5.8xlarge
      - m5a.large
      - m5a.xlarge
      - m5a.2xlarge
      - m5a.4xlarge
      - m5a.8xlarge
      - r5a.large
      - r5a.xlarge
      - r5a.2xlarge
      - r5a.4xlarge
      - r5a.8xlarge
      - r5.large
      - r5.xlarge
      - r5.2xlarge
      - r5.4xlarge
      - r5.8xlarge
    ConstraintDescription: Must be a valid EC2 instance type. 
  RDSInstanceType:
    Description: Amazon RDS Aurora Instance Type
    Type: String
    Default: db.r4.2xlarge
    AllowedValues:
      - db.r4.large
      - db.r4.xlarge
      - db.r4.2xlarge
      - db.r4.4xlarge
      - db.r4.8xlarge
      - db.r4.16xlarge
    ConstraintDescription: Must be a valid Amazon RDS instance type.
Conditions:
  GovCloudCondition: !Equals
    - !Ref 'AWS::Region'
    - us-gov-west-1
Resources:
  SrcVPCStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub
        - https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/aws-vpc.template
        - QSS3Region: !If
            - GovCloudCondition
            - s3-us-gov-west-1
            - s3
      Parameters:
        AvailabilityZones: !Ref 'SrcAvailabilityZones'
        NumberOfAZs: '2'
        PrivateSubnet1ACIDR: !Ref 'SrcPrivateSubnet1CIDR'
        PrivateSubnet2ACIDR: !Ref 'SrcPrivateSubnet2CIDR'
        PublicSubnet1CIDR: !Ref 'SrcPublicSubnet1CIDR'
        PublicSubnet2CIDR: !Ref 'SrcPublicSubnet2CIDR'
        VPCCIDR: !Ref 'SrcVPCCIDR'
  DestVPCStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub
        - https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/aws-vpc.template
        - QSS3Region: !If
            - GovCloudCondition
            - s3-us-gov-west-1
            - s3
      Parameters:
        AvailabilityZones: !Ref 'DestAvailabilityZones'
        NumberOfAZs: '2'
        PrivateSubnet1ACIDR: !Ref 'DestPrivateSubnet1CIDR'
        PrivateSubnet2ACIDR: !Ref 'DestPrivateSubnet2CIDR'
        PublicSubnet1CIDR: !Ref 'DestPublicSubnet1CIDR'
        PublicSubnet2CIDR: !Ref 'DestPublicSubnet2CIDR'
        VPCCIDR: !Ref 'DestVPCCIDR'
  ADStack:
    DependsOn: DestVPCStack
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub
        - https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/ad-3.template
        - QSS3Region: !If
            - GovCloudCondition
            - s3-us-gov-west-1
            - s3
      Parameters:
        DomainAdminPassword: !Ref 'DomainAdminPassword'
        DomainDNSName: !Ref 'DomainDNSName'
        DomainNetBIOSName: !Ref 'DomainNetBIOSName'
        ADEdition: !Ref 'ADEdition'
        PrivateSubnet1CIDR: !Ref 'DestPrivateSubnet1CIDR'
        PrivateSubnet1ID: !GetAtt 'DestVPCStack.Outputs.PrivateSubnet1AID'
        PrivateSubnet2CIDR: !Ref 'DestPrivateSubnet2CIDR'
        PrivateSubnet2ID: !GetAtt 'DestVPCStack.Outputs.PrivateSubnet2AID'
        PublicSubnet1CIDR: !Ref 'DestPublicSubnet1CIDR'
        PublicSubnet2CIDR: !Ref 'DestPublicSubnet2CIDR'
        QSS3BucketName: !Ref 'QSS3BucketName'
        QSS3KeyPrefix: !Ref 'QSS3KeyPrefix'
        VPCCIDR: !Ref 'DestVPCCIDR'
        VPCID: !GetAtt 'DestVPCStack.Outputs.VPCID'
  DestRDGWStack:
    DependsOn: ADStack
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub ['https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/rdgw-domain.template',
        {QSS3Region: !If [GovCloudCondition, s3-us-gov-west-1, s3]}]
      Parameters:
        DomainAdminPassword: !Ref 'DomainAdminPassword'
        DomainAdminUser: 'Admin'
        DomainDNSName: !Ref 'DomainDNSName'
        DomainMemberSGID: !GetAtt 'ADStack.Outputs.DomainMemberSGID'
        DomainNetBIOSName: !Ref 'DomainNetBIOSName'
        NumberOfRDGWHosts: !Ref 'NumberOfRDGWHosts'
        PublicSubnet1ID: !GetAtt 'DestVPCStack.Outputs.PublicSubnet1ID'
        PublicSubnet2ID: !GetAtt 'DestVPCStack.Outputs.PublicSubnet2ID'
        QSS3BucketName: !Ref 'QSS3BucketName'
        QSS3KeyPrefix: !Sub '${QSS3KeyPrefix}'
        RDGWInstanceType: !Ref 'RDGWInstanceType'
        RDGWCIDR: !Ref 'RDGWCIDR'
        VPCID: !GetAtt 'DestVPCStack.Outputs.VPCID'
  FSx:
    DependsOn: ADStack
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub
        - https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/fsx-mad.yml
        - QSS3Region: !If
            - GovCloudCondition
            - s3-us-gov-west-1
            - s3
      Parameters:
        ADId: !GetAtt 'ADStack.Outputs.DirectoryID'
        PrivateSubnet1: !GetAtt 'DestVPCStack.Outputs.PrivateSubnet1AID'
  MigrationInstances:
    DependsOn: ADStack
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub
        - https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/windowsinstances.yaml
        - QSS3Region: !If
            - GovCloudCondition
            - s3-us-gov-west-1
            - s3
      Parameters:
        SourceLocation: !Ref 'SrcVPCCIDR'
        SecretsARN: !GetAtt 'ADStack.Outputs.ADSecretsArn'
        SubnetID: !GetAtt 'SrcVPCStack.Outputs.PublicSubnet1ID'
        VPCID: !GetAtt 'SrcVPCStack.Outputs.VPCID'
  DMSWorkshop:
    DependsOn: 
      - DestVPCStack
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub
        - https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/DMSWorkshop.yaml
        - QSS3Region: !If
            - GovCloudCondition
            - s3-us-gov-west-1
            - s3
      Parameters:
        LabType: !Ref 'LabType'
        VpcCIDR: !Ref 'DestVPCCIDR'
        EC2ServerInstanceType: !Ref 'EC2ServerInstanceType'
        RDSInstanceType: !Ref 'RDSInstanceType'
        Subnet1: !GetAtt 'DestVPCStack.Outputs.PrivateSubnet1AID'
        Subnet2: !GetAtt 'DestVPCStack.Outputs.PrivateSubnet2AID'
        VPCID: !GetAtt 'DestVPCStack.Outputs.VPCID'
        SSMInstanceProfile: !GetAtt 'MigrationInstances.Outputs.SSMInstanceProfileName'
```

### VPC Template taken from [VPC Quickstart](https://github.com/aws-quickstart/quickstart-aws-vpc)

```JSON
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "This template creates a Multi-AZ, multi-subnet VPC infrastructure with managed NAT gateways in the public subnet for each Availability Zone. You can also create additional private subnets with dedicated custom network access control lists (ACLs). If you deploy the Quick Start in a region that doesn't support NAT gateways, NAT instances are deployed instead. **WARNING** This template creates AWS resources. You will be billed for the AWS resources used if you create a stack from this template. QS(0027)",
    "Metadata": {
        "AWS::CloudFormation::Interface": {
            "ParameterGroups": [
                {
                    "Label": {
                        "default": "Availability Zone Configuration"
                    },
                    "Parameters": [
                        "AvailabilityZones",
                        "NumberOfAZs"
                    ]
                },
                {
                    "Label": {
                        "default": "Network Configuration"
                    },
                    "Parameters": [
                        "VPCCIDR",
                        "PublicSubnet1CIDR",
                        "PublicSubnet2CIDR",
                        "PublicSubnet3CIDR",
                        "PublicSubnet4CIDR",
                        "PublicSubnetTag1",
                        "PublicSubnetTag2",
                        "PublicSubnetTag3",
                        "CreatePrivateSubnets",
                        "PrivateSubnet1ACIDR",
                        "PrivateSubnet2ACIDR",
                        "PrivateSubnet3ACIDR",
                        "PrivateSubnet4ACIDR",
                        "PrivateSubnetATag1",
                        "PrivateSubnetATag2",
                        "PrivateSubnetATag3",
                        "CreateAdditionalPrivateSubnets",
                        "PrivateSubnet1BCIDR",
                        "PrivateSubnet2BCIDR",
                        "PrivateSubnet3BCIDR",
                        "PrivateSubnet4BCIDR",
                        "PrivateSubnetBTag1",
                        "PrivateSubnetBTag2",
                        "PrivateSubnetBTag3",
                        "VPCTenancy"
                    ]
                },
                {
                    "Label": {
                        "default": "Deprecated: NAT Instance Configuration"
                    },
                    "Parameters": [
                        "KeyPairName",
                        "NATInstanceType"
                    ]
                }
            ],
            "ParameterLabels": {
                "AvailabilityZones": {
                    "default": "Availability Zones"
                },
                "CreateAdditionalPrivateSubnets": {
                    "default": "Create additional private subnets with dedicated network ACLs"
                },
                "CreatePrivateSubnets": {
                    "default": "Create private subnets"
                },
                "KeyPairName": {
                    "default": "Deprecated: Key pair name"
                },
                "NATInstanceType": {
                    "default": "Deprecated: NAT instance type"
                },
                "NumberOfAZs": {
                    "default": "Number of Availability Zones"
                },
                "PrivateSubnet1ACIDR": {
                    "default": "Private subnet 1A CIDR"
                },
                "PrivateSubnet1BCIDR": {
                    "default": "Private subnet 1B with dedicated network ACL CIDR"
                },
                "PrivateSubnet2ACIDR": {
                    "default": "Private subnet 2A CIDR"
                },
                "PrivateSubnet2BCIDR": {
                    "default": "Private subnet 2B with dedicated network ACL CIDR"
                },
                "PrivateSubnet3ACIDR": {
                    "default": "Private subnet 3A CIDR"
                },
                "PrivateSubnet3BCIDR": {
                    "default": "Private subnet 3B with dedicated network ACL CIDR"
                },
                "PrivateSubnet4ACIDR": {
                    "default": "Private subnet 4A CIDR"
                },
                "PrivateSubnet4BCIDR": {
                    "default": "Private subnet 4B with dedicated network ACL CIDR"
                },
                "PrivateSubnetATag1": {
                    "default": "Tag for Private A Subnets"
                },
                "PrivateSubnetATag2": {
                    "default": "Tag for Private A Subnets"
                },
                "PrivateSubnetATag3": {
                    "default": "Tag for Private A Subnets"
                },
                "PrivateSubnetBTag1": {
                    "default": "Tag for Private B Subnets"
                },
                "PrivateSubnetBTag2": {
                    "default": "Tag for Private B Subnets"
                },
                "PrivateSubnetBTag3": {
                    "default": "Tag for Private B Subnets"
                },
                "PublicSubnet1CIDR": {
                    "default": "Public subnet 1 CIDR"
                },
                "PublicSubnet2CIDR": {
                    "default": "Public subnet 2 CIDR"
                },
                "PublicSubnet3CIDR": {
                    "default": "Public subnet 3 CIDR"
                },
                "PublicSubnet4CIDR": {
                    "default": "Public subnet 4 CIDR"
                },
                "PublicSubnetTag1": {
                    "default": "Tag for Public Subnets"
                },
                "PublicSubnetTag2": {
                    "default": "Tag for Public Subnets"
                },
                "PublicSubnetTag3": {
                    "default": "Tag for Public Subnets"
                },
                "VPCCIDR": {
                    "default": "VPC CIDR"
                },
                "VPCTenancy": {
                    "default": "VPC Tenancy"
                }
            }
        }
    },
    "Parameters": {
        "AvailabilityZones": {
            "Description": "List of Availability Zones to use for the subnets in the VPC. Note: The logical order is preserved.",
            "Type": "List<AWS::EC2::AvailabilityZone::Name>"
        },
        "CreateAdditionalPrivateSubnets": {
            "AllowedValues": [
                "true",
                "false"
            ],
            "Default": "false",
            "Description": "Set to true to create a network ACL protected subnet in each Availability Zone. If false, the CIDR parameters for those subnets will be ignored. If true, it also requires that the 'Create private subnets' parameter is also true to have any effect.",
            "Type": "String"
        },
        "CreatePrivateSubnets": {
            "AllowedValues": [
                "true",
                "false"
            ],
            "Default": "true",
            "Description": "Set to false to create only public subnets. If false, the CIDR parameters for ALL private subnets will be ignored.",
            "Type": "String"
        },
        "KeyPairName": {
            "Description": "Deprecated. NAT gateways are now supported in all regions.",
            "Type": "String",
            "Default": "deprecated"
        },
        "NATInstanceType": {
            "Default": "deprecated",
            "Description": "Deprecated. NAT gateways are now supported in all regions.",
            "Type": "String"
        },
        "NumberOfAZs": {
            "AllowedValues": [
                "2",
                "3",
                "4"
            ],
            "Default": "2",
            "Description": "Number of Availability Zones to use in the VPC. This must match your selections in the list of Availability Zones parameter.",
            "Type": "String"
        },
        "PrivateSubnet1ACIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.0.0/19",
            "Description": "CIDR block for private subnet 1A located in Availability Zone 1",
            "Type": "String"
        },
        "PrivateSubnet1BCIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.192.0/21",
            "Description": "CIDR block for private subnet 1B with dedicated network ACL located in Availability Zone 1",
            "Type": "String"
        },
        "PrivateSubnet2ACIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.32.0/19",
            "Description": "CIDR block for private subnet 2A located in Availability Zone 2",
            "Type": "String"
        },
        "PrivateSubnet2BCIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.200.0/21",
            "Description": "CIDR block for private subnet 2B with dedicated network ACL located in Availability Zone 2",
            "Type": "String"
        },
        "PrivateSubnet3ACIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.64.0/19",
            "Description": "CIDR block for private subnet 3A located in Availability Zone 3",
            "Type": "String"
        },
        "PrivateSubnet3BCIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.208.0/21",
            "Description": "CIDR block for private subnet 3B with dedicated network ACL located in Availability Zone 3",
            "Type": "String"
        },
        "PrivateSubnet4ACIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.96.0/19",
            "Description": "CIDR block for private subnet 4A located in Availability Zone 4",
            "Type": "String"
        },
        "PrivateSubnet4BCIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.216.0/21",
            "Description": "CIDR block for private subnet 4B with dedicated network ACL located in Availability Zone 4",
            "Type": "String"
        },
        "PrivateSubnetATag1": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "Network=Private",
            "Description": "tag to add to private subnets A, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PrivateSubnetATag2": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "",
            "Description": "tag to add to private subnets A, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PrivateSubnetATag3": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "",
            "Description": "tag to add to private subnets A, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PrivateSubnetBTag1": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "Network=Private",
            "Description": "tag to add to private subnets B, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PrivateSubnetBTag2": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "",
            "Description": "tag to add to private subnets B, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PrivateSubnetBTag3": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "",
            "Description": "tag to add to private subnets B, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PublicSubnet1CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.128.0/20",
            "Description": "CIDR block for the public DMZ subnet 1 located in Availability Zone 1",
            "Type": "String"
        },
        "PublicSubnet2CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.144.0/20",
            "Description": "CIDR block for the public DMZ subnet 2 located in Availability Zone 2",
            "Type": "String"
        },
        "PublicSubnet3CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.160.0/20",
            "Description": "CIDR block for the public DMZ subnet 3 located in Availability Zone 3",
            "Type": "String"
        },
        "PublicSubnet4CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.176.0/20",
            "Description": "CIDR block for the public DMZ subnet 4 located in Availability Zone 4",
            "Type": "String"
        },
        "PublicSubnetTag1": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "Network=Public",
            "Description": "tag to add to public subnets, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PublicSubnetTag2": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "",
            "Description": "tag to add to public subnets, in format Key=Value (Optional)",
            "Type": "String"
        },
        "PublicSubnetTag3": {
            "AllowedPattern": "^([a-zA-Z0-9+\\-._:/@]+=[a-zA-Z0-9+\\-.,_:/@ *\\\\\"'\\[\\]\\{\\}]*)?$",
            "ConstraintDescription": "tags must be in format \"Key=Value\" keys can only contain [a-zA-Z0-9+\\-._:/@], values can contain [a-zA-Z0-9+\\-._:/@ *\\\\\"'\\[\\]\\{\\}]",
            "Default": "",
            "Description": "tag to add to public subnets, in format Key=Value (Optional)",
            "Type": "String"
        },
        "VPCCIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.0.0/16",
            "Description": "CIDR block for the VPC",
            "Type": "String"
        },
        "VPCTenancy": {
            "AllowedValues": [
                "default",
                "dedicated"
            ],
            "Default": "default",
            "Description": "The allowed tenancy of instances launched into the VPC",
            "Type": "String"
        }
    },
    "Conditions": {
        "3AZCondition": {
            "Fn::Or": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "NumberOfAZs"
                        },
                        "3"
                    ]
                },
                {
                    "Condition": "4AZCondition"
                }
            ]
        },
        "4AZCondition": {
            "Fn::Equals": [
                {
                    "Ref": "NumberOfAZs"
                },
                "4"
            ]
        },
        "AdditionalPrivateSubnetsCondition": {
            "Fn::And": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "CreatePrivateSubnets"
                        },
                        "true"
                    ]
                },
                {
                    "Fn::Equals": [
                        {
                            "Ref": "CreateAdditionalPrivateSubnets"
                        },
                        "true"
                    ]
                }
            ]
        },
        "AdditionalPrivateSubnets&3AZCondition": {
            "Fn::And": [
                {
                    "Condition": "AdditionalPrivateSubnetsCondition"
                },
                {
                    "Condition": "3AZCondition"
                }
            ]
        },
        "AdditionalPrivateSubnets&4AZCondition": {
            "Fn::And": [
                {
                    "Condition": "AdditionalPrivateSubnetsCondition"
                },
                {
                    "Condition": "4AZCondition"
                }
            ]
        },
        "GovCloudCondition": {
            "Fn::Equals": [
                {
                    "Ref": "AWS::Region"
                },
                "us-gov-west-1"
            ]
        },
        "NVirginiaRegionCondition": {
            "Fn::Equals": [
                {
                    "Ref": "AWS::Region"
                },
                "us-east-1"
            ]
        },
        "PrivateSubnetsCondition": {
            "Fn::Equals": [
                {
                    "Ref": "CreatePrivateSubnets"
                },
                "true"
            ]
        },
        "PrivateSubnets&3AZCondition": {
            "Fn::And": [
                {
                    "Condition": "PrivateSubnetsCondition"
                },
                {
                    "Condition": "3AZCondition"
                }
            ]
        },
        "PrivateSubnets&4AZCondition": {
            "Fn::And": [
                {
                    "Condition": "PrivateSubnetsCondition"
                },
                {
                    "Condition": "4AZCondition"
                }
            ]
        },
        "PrivateSubnetATag1Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PrivateSubnetATag1"
                        },
                        ""
                    ]
                }
            ]
        },
        "PrivateSubnetATag2Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PrivateSubnetATag2"
                        },
                        ""
                    ]
                }
            ]
        },
        "PrivateSubnetATag3Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PrivateSubnetATag3"
                        },
                        ""
                    ]
                }
            ]
        },
        "PrivateSubnetBTag1Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PrivateSubnetBTag1"
                        },
                        ""
                    ]
                }
            ]
        },
        "PrivateSubnetBTag2Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PrivateSubnetBTag2"
                        },
                        ""
                    ]
                }
            ]
        },
        "PrivateSubnetBTag3Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PrivateSubnetBTag3"
                        },
                        ""
                    ]
                }
            ]
        },
        "PublicSubnetTag1Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PublicSubnetTag1"
                        },
                        ""
                    ]
                }
            ]
        },
        "PublicSubnetTag2Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PublicSubnetTag2"
                        },
                        ""
                    ]
                }
            ]
        },
        "PublicSubnetTag3Condition": {
            "Fn::Not": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "PublicSubnetTag3"
                        },
                        ""
                    ]
                }
            ]
        }
    },
    "Resources": {
        "DHCPOptions": {
            "Type": "AWS::EC2::DHCPOptions",
            "Properties": {
                "DomainName": {
                    "Fn::If": [
                        "NVirginiaRegionCondition",
                        "ec2.internal",
                        {
                            "Fn::Sub": "${AWS::Region}.compute.internal"
                        }
                    ]
                },
                "DomainNameServers": [
                    "AmazonProvidedDNS"
                ]
            }
        },
        "VPC": {
            "Type": "AWS::EC2::VPC",
            "Properties": {
                "CidrBlock": {
                    "Ref": "VPCCIDR"
                },
                "InstanceTenancy": {
                    "Ref": "VPCTenancy"
                },
                "EnableDnsSupport": true,
                "EnableDnsHostnames": true,
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": {
                            "Ref": "AWS::StackName"
                        }
                    }
                ]
            }
        },
        "VPCDHCPOptionsAssociation": {
            "Type": "AWS::EC2::VPCDHCPOptionsAssociation",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "DhcpOptionsId": {
                    "Ref": "DHCPOptions"
                }
            }
        },
        "InternetGateway": {
            "Type": "AWS::EC2::InternetGateway",
            "Properties": {
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": {
                            "Ref": "AWS::StackName"
                        }
                    }
                ]
            }
        },
        "VPCGatewayAttachment": {
            "Type": "AWS::EC2::VPCGatewayAttachment",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "InternetGatewayId": {
                    "Ref": "InternetGateway"
                }
            }
        },
        "PrivateSubnet1A": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet1ACIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "0",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 1A"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PrivateSubnet1B": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet1BCIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "0",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 1B"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PrivateSubnet2A": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet2ACIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "1",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 2A"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PrivateSubnet2B": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet2BCIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "1",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 2B"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PrivateSubnet3A": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet3ACIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "2",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 3A"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PrivateSubnet3B": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet3BCIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "2",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 3B"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PrivateSubnet4A": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet4ACIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "3",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 4A"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetATag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetATag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PrivateSubnet4B": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PrivateSubnet4BCIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "3",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 4B"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnetBTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PrivateSubnetBTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ]
            }
        },
        "PublicSubnet1": {
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PublicSubnet1CIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "0",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Public subnet 1"
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ],
                "MapPublicIpOnLaunch": true
            }
        },
        "PublicSubnet2": {
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PublicSubnet2CIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "1",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Public subnet 2"
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ],
                "MapPublicIpOnLaunch": true
            }
        },
        "PublicSubnet3": {
            "Condition": "3AZCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PublicSubnet3CIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "2",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Public subnet 3"
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ],
                "MapPublicIpOnLaunch": true
            }
        },
        "PublicSubnet4": {
            "Condition": "4AZCondition",
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "PublicSubnet4CIDR"
                },
                "AvailabilityZone": {
                    "Fn::Select": [
                        "3",
                        {
                            "Ref": "AvailabilityZones"
                        }
                    ]
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Public subnet 4"
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag1Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag1"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag2Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag2"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PublicSubnetTag3Condition",
                            {
                                "Key": {
                                    "Fn::Select": [
                                        "0",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                "Value": {
                                    "Fn::Select": [
                                        "1",
                                        {
                                            "Fn::Split": [
                                                "=",
                                                {
                                                    "Ref": "PublicSubnetTag3"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ],
                "MapPublicIpOnLaunch": true
            }
        },
        "PrivateSubnet1ARouteTable": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 1A"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet1ARoute": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet1ARouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway1"
                }
            }
        },
        "PrivateSubnet1ARouteTableAssociation": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet1A"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet1ARouteTable"
                }
            }
        },
        "PrivateSubnet2ARouteTable": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 2A"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet2ARoute": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet2ARouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway2"
                }
            }
        },
        "PrivateSubnet2ARouteTableAssociation": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet2A"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet2ARouteTable"
                }
            }
        },
        "PrivateSubnet3ARouteTable": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 3A"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet3ARoute": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet3ARouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway3"
                }
            }
        },
        "PrivateSubnet3ARouteTableAssociation": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet3A"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet3ARouteTable"
                }
            }
        },
        "PrivateSubnet4ARouteTable": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 4A"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet4ARoute": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet4ARouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway4"
                }
            }
        },
        "PrivateSubnet4ARouteTableAssociation": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet4A"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet4ARouteTable"
                }
            }
        },
        "PrivateSubnet1BRouteTable": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 1B"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet1BRoute": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet1BRouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway1"
                }
            }
        },
        "PrivateSubnet1BRouteTableAssociation": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet1B"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet1BRouteTable"
                }
            }
        },
        "PrivateSubnet1BNetworkAcl": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::NetworkAcl",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "NACL Protected subnet 1"
                    },
                    {
                        "Key": "Network",
                        "Value": "NACL Protected"
                    }
                ]
            }
        },
        "PrivateSubnet1BNetworkAclEntryInbound": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": false,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet1BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet1BNetworkAclEntryOutbound": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": true,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet1BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet1BNetworkAclAssociation": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::SubnetNetworkAclAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet1B"
                },
                "NetworkAclId": {
                    "Ref": "PrivateSubnet1BNetworkAcl"
                }
            }
        },
        "PrivateSubnet2BRouteTable": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 2B"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet2BRoute": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet2BRouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway2"
                }
            }
        },
        "PrivateSubnet2BRouteTableAssociation": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet2B"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet2BRouteTable"
                }
            }
        },
        "PrivateSubnet2BNetworkAcl": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::NetworkAcl",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "NACL Protected subnet 2"
                    },
                    {
                        "Key": "Network",
                        "Value": "NACL Protected"
                    }
                ]
            }
        },
        "PrivateSubnet2BNetworkAclEntryInbound": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": false,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet2BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet2BNetworkAclEntryOutbound": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": true,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet2BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet2BNetworkAclAssociation": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Type": "AWS::EC2::SubnetNetworkAclAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet2B"
                },
                "NetworkAclId": {
                    "Ref": "PrivateSubnet2BNetworkAcl"
                }
            }
        },
        "PrivateSubnet3BRouteTable": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 3B"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet3BRoute": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet3BRouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway3"
                }
            }
        },
        "PrivateSubnet3BRouteTableAssociation": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet3B"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet3BRouteTable"
                }
            }
        },
        "PrivateSubnet3BNetworkAcl": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::NetworkAcl",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "NACL Protected subnet 3"
                    },
                    {
                        "Key": "Network",
                        "Value": "NACL Protected"
                    }
                ]
            }
        },
        "PrivateSubnet3BNetworkAclEntryInbound": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": false,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet3BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet3BNetworkAclEntryOutbound": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": true,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet3BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet3BNetworkAclAssociation": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Type": "AWS::EC2::SubnetNetworkAclAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet3B"
                },
                "NetworkAclId": {
                    "Ref": "PrivateSubnet3BNetworkAcl"
                }
            }
        },
        "PrivateSubnet4BRouteTable": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Private subnet 4B"
                    },
                    {
                        "Key": "Network",
                        "Value": "Private"
                    }
                ]
            }
        },
        "PrivateSubnet4BRoute": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PrivateSubnet4BRouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "NatGatewayId": {
                    "Ref": "NATGateway4"
                }
            }
        },
        "PrivateSubnet4BRouteTableAssociation": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet4B"
                },
                "RouteTableId": {
                    "Ref": "PrivateSubnet4BRouteTable"
                }
            }
        },
        "PrivateSubnet4BNetworkAcl": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::NetworkAcl",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "NACL Protected subnet 4"
                    },
                    {
                        "Key": "Network",
                        "Value": "NACL Protected"
                    }
                ]
            }
        },
        "PrivateSubnet4BNetworkAclEntryInbound": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": false,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet4BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet4BNetworkAclEntryOutbound": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::NetworkAclEntry",
            "Properties": {
                "CidrBlock": "0.0.0.0/0",
                "Egress": true,
                "NetworkAclId": {
                    "Ref": "PrivateSubnet4BNetworkAcl"
                },
                "Protocol": -1,
                "RuleAction": "allow",
                "RuleNumber": 100
            }
        },
        "PrivateSubnet4BNetworkAclAssociation": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Type": "AWS::EC2::SubnetNetworkAclAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PrivateSubnet4B"
                },
                "NetworkAclId": {
                    "Ref": "PrivateSubnet4BNetworkAcl"
                }
            }
        },
        "PublicSubnetRouteTable": {
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Public Subnets"
                    },
                    {
                        "Key": "Network",
                        "Value": "Public"
                    }
                ]
            }
        },
        "PublicSubnetRoute": {
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::Route",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PublicSubnetRouteTable"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "GatewayId": {
                    "Ref": "InternetGateway"
                }
            }
        },
        "PublicSubnet1RouteTableAssociation": {
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PublicSubnet1"
                },
                "RouteTableId": {
                    "Ref": "PublicSubnetRouteTable"
                }
            }
        },
        "PublicSubnet2RouteTableAssociation": {
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PublicSubnet2"
                },
                "RouteTableId": {
                    "Ref": "PublicSubnetRouteTable"
                }
            }
        },
        "PublicSubnet3RouteTableAssociation": {
            "Condition": "3AZCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PublicSubnet3"
                },
                "RouteTableId": {
                    "Ref": "PublicSubnetRouteTable"
                }
            }
        },
        "PublicSubnet4RouteTableAssociation": {
            "Condition": "4AZCondition",
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "PublicSubnet4"
                },
                "RouteTableId": {
                    "Ref": "PublicSubnetRouteTable"
                }
            }
        },
        "NAT1EIP": {
            "Condition": "PrivateSubnetsCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::EIP",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "NAT2EIP": {
            "Condition": "PrivateSubnetsCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::EIP",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "NAT3EIP": {
            "Condition": "PrivateSubnets&3AZCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::EIP",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "NAT4EIP": {
            "Condition": "PrivateSubnets&4AZCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::EIP",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "NATGateway1": {
            "Condition": "PrivateSubnetsCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::NatGateway",
            "Properties": {
                "AllocationId": {
                    "Fn::GetAtt": [
                        "NAT1EIP",
                        "AllocationId"
                    ]
                },
                "SubnetId": {
                    "Ref": "PublicSubnet1"
                }
            }
        },
        "NATGateway2": {
            "Condition": "PrivateSubnetsCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::NatGateway",
            "Properties": {
                "AllocationId": {
                    "Fn::GetAtt": [
                        "NAT2EIP",
                        "AllocationId"
                    ]
                },
                "SubnetId": {
                    "Ref": "PublicSubnet2"
                }
            }
        },
        "NATGateway3": {
            "Condition": "PrivateSubnets&3AZCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::NatGateway",
            "Properties": {
                "AllocationId": {
                    "Fn::GetAtt": [
                        "NAT3EIP",
                        "AllocationId"
                    ]
                },
                "SubnetId": {
                    "Ref": "PublicSubnet3"
                }
            }
        },
        "NATGateway4": {
            "Condition": "PrivateSubnets&4AZCondition",
            "DependsOn": "VPCGatewayAttachment",
            "Type": "AWS::EC2::NatGateway",
            "Properties": {
                "AllocationId": {
                    "Fn::GetAtt": [
                        "NAT4EIP",
                        "AllocationId"
                    ]
                },
                "SubnetId": {
                    "Ref": "PublicSubnet4"
                }
            }
        },
        "S3VPCEndpoint": {
            "Condition": "PrivateSubnetsCondition",
            "Type": "AWS::EC2::VPCEndpoint",
            "Properties": {
                "PolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Action": "*",
                            "Effect": "Allow",
                            "Resource": "*",
                            "Principal": "*"
                        }
                    ]
                },
                "RouteTableIds": [
                    {
                        "Ref": "PrivateSubnet1ARouteTable"
                    },
                    {
                        "Ref": "PrivateSubnet2ARouteTable"
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnets&3AZCondition",
                            {
                                "Ref": "PrivateSubnet3ARouteTable"
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "PrivateSubnets&4AZCondition",
                            {
                                "Ref": "PrivateSubnet4ARouteTable"
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "AdditionalPrivateSubnetsCondition",
                            {
                                "Ref": "PrivateSubnet1BRouteTable"
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "AdditionalPrivateSubnetsCondition",
                            {
                                "Ref": "PrivateSubnet2BRouteTable"
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "AdditionalPrivateSubnets&3AZCondition",
                            {
                                "Ref": "PrivateSubnet3BRouteTable"
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    {
                        "Fn::If": [
                            "AdditionalPrivateSubnets&4AZCondition",
                            {
                                "Ref": "PrivateSubnet4BRouteTable"
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    }
                ],
                "ServiceName": {
                    "Fn::Sub": "com.amazonaws.${AWS::Region}.s3"
                },
                "VpcId": {
                    "Ref": "VPC"
                }
            }
        }
    },
    "Outputs": {
        "NAT1EIP": {
            "Condition": "PrivateSubnetsCondition",
            "Description": "NAT 1 IP address",
            "Value": {
                "Ref": "NAT1EIP"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-NAT1EIP"
                }
            }
        },
        "NAT2EIP": {
            "Condition": "PrivateSubnetsCondition",
            "Description": "NAT 2 IP address",
            "Value": {
                "Ref": "NAT2EIP"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-NAT2EIP"
                }
            }
        },
        "NAT3EIP": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Description": "NAT 3 IP address",
            "Value": {
                "Ref": "NAT3EIP"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-NAT3EIP"
                }
            }
        },
        "NAT4EIP": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Description": "NAT 4 IP address",
            "Value": {
                "Ref": "NAT4EIP"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-NAT4EIP"
                }
            }
        },
        "PrivateSubnet1ACIDR": {
            "Condition": "PrivateSubnetsCondition",
            "Description": "Private subnet 1A CIDR in Availability Zone 1",
            "Value": {
                "Ref": "PrivateSubnet1ACIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet1ACIDR"
                }
            }
        },
        "PrivateSubnet1AID": {
            "Condition": "PrivateSubnetsCondition",
            "Description": "Private subnet 1A ID in Availability Zone 1",
            "Value": {
                "Ref": "PrivateSubnet1A"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet1AID"
                }
            }
        },
        "PrivateSubnet1BCIDR": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Description": "Private subnet 1B CIDR in Availability Zone 1",
            "Value": {
                "Ref": "PrivateSubnet1BCIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet1BCIDR"
                }
            }
        },
        "PrivateSubnet1BID": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Description": "Private subnet 1B ID in Availability Zone 1",
            "Value": {
                "Ref": "PrivateSubnet1B"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet1BID"
                }
            }
        },
        "PrivateSubnet2ACIDR": {
            "Condition": "PrivateSubnetsCondition",
            "Description": "Private subnet 2A CIDR in Availability Zone 2",
            "Value": {
                "Ref": "PrivateSubnet2ACIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet2ACIDR"
                }
            }
        },
        "PrivateSubnet2AID": {
            "Condition": "PrivateSubnetsCondition",
            "Description": "Private subnet 2A ID in Availability Zone 2",
            "Value": {
                "Ref": "PrivateSubnet2A"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet2AID"
                }
            }
        },
        "PrivateSubnet2BCIDR": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Description": "Private subnet 2B CIDR in Availability Zone 2",
            "Value": {
                "Ref": "PrivateSubnet2BCIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet2BCIDR"
                }
            }
        },
        "PrivateSubnet2BID": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Description": "Private subnet 2B ID in Availability Zone 2",
            "Value": {
                "Ref": "PrivateSubnet2B"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet2BID"
                }
            }
        },
        "PrivateSubnet3ACIDR": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Description": "Private subnet 3A CIDR in Availability Zone 3",
            "Value": {
                "Ref": "PrivateSubnet3ACIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet3ACIDR"
                }
            }
        },
        "PrivateSubnet3AID": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Description": "Private subnet 3A ID in Availability Zone 3",
            "Value": {
                "Ref": "PrivateSubnet3A"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet3AID"
                }
            }
        },
        "PrivateSubnet3BCIDR": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Description": "Private subnet 3B CIDR in Availability Zone 3",
            "Value": {
                "Ref": "PrivateSubnet3BCIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet3BCIDR"
                }
            }
        },
        "PrivateSubnet3BID": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Description": "Private subnet 3B ID in Availability Zone 3",
            "Value": {
                "Ref": "PrivateSubnet3B"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet3BID"
                }
            }
        },
        "PrivateSubnet4ACIDR": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Description": "Private subnet 4A CIDR in Availability Zone 4",
            "Value": {
                "Ref": "PrivateSubnet4ACIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet4ACIDR"
                }
            }
        },
        "PrivateSubnet4AID": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Description": "Private subnet 4A ID in Availability Zone 4",
            "Value": {
                "Ref": "PrivateSubnet4A"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet4AID"
                }
            }
        },
        "PrivateSubnet4BCIDR": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Description": "Private subnet 4B CIDR in Availability Zone 4",
            "Value": {
                "Ref": "PrivateSubnet4BCIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet4BCIDR"
                }
            }
        },
        "PrivateSubnet4BID": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Description": "Private subnet 4B ID in Availability Zone 4",
            "Value": {
                "Ref": "PrivateSubnet4B"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet4BID"
                }
            }
        },
        "PublicSubnet1CIDR": {
            "Description": "Public subnet 1 CIDR in Availability Zone 1",
            "Value": {
                "Ref": "PublicSubnet1CIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet1CIDR"
                }
            }
        },
        "PublicSubnet1ID": {
            "Description": "Public subnet 1 ID in Availability Zone 1",
            "Value": {
                "Ref": "PublicSubnet1"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet1ID"
                }
            }
        },
        "PublicSubnet2CIDR": {
            "Description": "Public subnet 2 CIDR in Availability Zone 2",
            "Value": {
                "Ref": "PublicSubnet2CIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet2CIDR"
                }
            }
        },
        "PublicSubnet2ID": {
            "Description": "Public subnet 2 ID in Availability Zone 2",
            "Value": {
                "Ref": "PublicSubnet2"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet2ID"
                }
            }
        },
        "PublicSubnet3CIDR": {
            "Condition": "3AZCondition",
            "Description": "Public subnet 3 CIDR in Availability Zone 3",
            "Value": {
                "Ref": "PublicSubnet3CIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet3CIDR"
                }
            }
        },
        "PublicSubnet3ID": {
            "Condition": "3AZCondition",
            "Description": "Public subnet 3 ID in Availability Zone 3",
            "Value": {
                "Ref": "PublicSubnet3"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet3ID"
                }
            }
        },
        "PublicSubnet4CIDR": {
            "Condition": "4AZCondition",
            "Description": "Public subnet 4 CIDR in Availability Zone 4",
            "Value": {
                "Ref": "PublicSubnet4CIDR"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet4CIDR"
                }
            }
        },
        "PublicSubnet4ID": {
            "Condition": "4AZCondition",
            "Description": "Public subnet 4 ID in Availability Zone 4",
            "Value": {
                "Ref": "PublicSubnet4"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnet4ID"
                }
            }
        },
        "S3VPCEndpoint": {
            "Condition": "PrivateSubnetsCondition",
            "Description": "S3 VPC Endpoint",
            "Value": {
                "Ref": "S3VPCEndpoint"
            },
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-S3VPCEndpoint"
                }
            }
        },
        "PrivateSubnet1ARouteTable": {
            "Condition": "PrivateSubnetsCondition",
            "Value": {
                "Ref": "PrivateSubnet1ARouteTable"
            },
            "Description": "Private subnet 1A route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet1ARouteTable"
                }
            }
        },
        "PrivateSubnet1BRouteTable": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Value": {
                "Ref": "PrivateSubnet1BRouteTable"
            },
            "Description": "Private subnet 1B route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet1BRouteTable"
                }
            }
        },
        "PrivateSubnet2ARouteTable": {
            "Condition": "PrivateSubnetsCondition",
            "Value": {
                "Ref": "PrivateSubnet2ARouteTable"
            },
            "Description": "Private subnet 2A route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet2ARouteTable"
                }
            }
        },
        "PrivateSubnet2BRouteTable": {
            "Condition": "AdditionalPrivateSubnetsCondition",
            "Value": {
                "Ref": "PrivateSubnet2BRouteTable"
            },
            "Description": "Private subnet 2B route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet2BRouteTable"
                }
            }
        },
        "PrivateSubnet3ARouteTable": {
            "Condition": "PrivateSubnets&3AZCondition",
            "Value": {
                "Ref": "PrivateSubnet3ARouteTable"
            },
            "Description": "Private subnet 3A route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet3ARouteTable"
                }
            }
        },
        "PrivateSubnet3BRouteTable": {
            "Condition": "AdditionalPrivateSubnets&3AZCondition",
            "Value": {
                "Ref": "PrivateSubnet3BRouteTable"
            },
            "Description": "Private subnet 3B route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet3BRouteTable"
                }
            }
        },
        "PrivateSubnet4ARouteTable": {
            "Condition": "PrivateSubnets&4AZCondition",
            "Value": {
                "Ref": "PrivateSubnet4ARouteTable"
            },
            "Description": "Private subnet 4A route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet4ARouteTable"
                }
            }
        },
        "PrivateSubnet4BRouteTable": {
            "Condition": "AdditionalPrivateSubnets&4AZCondition",
            "Value": {
                "Ref": "PrivateSubnet4BRouteTable"
            },
            "Description": "Private subnet 4B route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PrivateSubnet4BRouteTable"
                }
            }
        },
        "PublicSubnetRouteTable": {
            "Value": {
                "Ref": "PublicSubnetRouteTable"
            },
            "Description": "Public subnet route table",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-PublicSubnetRouteTable"
                }
            }
        },
        "VPCCIDR": {
            "Value": {
                "Ref": "VPCCIDR"
            },
            "Description": "VPC CIDR",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-VPCCIDR"
                }
            }
        },
        "VPCID": {
            "Value": {
                "Ref": "VPC"
            },
            "Description": "VPC ID",
            "Export": {
                "Name": {
                    "Fn::Sub": "${AWS::StackName}-VPCID"
                }
            }
        }
    }
}
```

### Managed Active Directory taken from [AD Quick Start Scenario 3](https://github.com/aws-quickstart/quickstart-microsoft-activedirectory)

```JSON
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "This template creates a managed Microsoft AD Directory Service into private subnets in separate Availability Zones inside a VPC. The default Domain Administrator user is 'admin'. For adding members to the domain, ensure that they are launched into the domain member security group created by this template and then configure them to use the AD instances fixed private IP addresses as the DNS server. **WARNING** This template creates Amazon EC2 Windows instance and related resources. You will be billed for the AWS resources used if you create a stack from this template. QS(0021)",
    "Metadata": {
        "AWS::CloudFormation::Interface": {
            "ParameterGroups": [
                {
                    "Label": {
                        "default": "Network Configuration"
                    },
                    "Parameters": [
                        "VPCCIDR",
                        "VPCID",
                        "PrivateSubnet1CIDR",
                        "PrivateSubnet1ID",
                        "PrivateSubnet2CIDR",
                        "PrivateSubnet2ID",
                        "PublicSubnet1CIDR",
                        "PublicSubnet2CIDR"
                    ]
                },
                {
                    "Label": {
                        "default": "Microsoft Active Directory Configuration"
                    },
                    "Parameters": [
                        "DomainDNSName",
                        "DomainNetBIOSName",
                        "DomainAdminPassword",
                        "ADEdition"
                    ]
                },
                {
                    "Label": {
                        "default": "AWS Quick Start Configuration"
                    },
                    "Parameters": [
                        "QSS3BucketName",
                        "QSS3KeyPrefix"
                    ]
                }
            ],
            "ParameterLabels": {
                "DomainAdminPassword": {
                    "default": "Domain Admin Password"
                },
                "DomainDNSName": {
                    "default": "Domain DNS Name"
                },
                "DomainNetBIOSName": {
                    "default": "Domain NetBIOS Name"
                },
                "ADEdition": {
                    "default": "AWS Microsoft AD edition"
                },
                "PrivateSubnet1CIDR": {
                    "default": "Private Subnet 1 CIDR"
                },
                "PrivateSubnet1ID": {
                    "default": "Private Subnet 1 ID"
                },
                "PrivateSubnet2CIDR": {
                    "default": "Private Subnet 2 CIDR"
                },
                "PrivateSubnet2ID": {
                    "default": "Private Subnet 2 ID"
                },
                "PublicSubnet1CIDR": {
                    "default": "Public Subnet 1 CIDR"
                },
                "PublicSubnet2CIDR": {
                    "default": "Public Subnet 2 CIDR"
                },
                "QSS3BucketName": {
                    "default": "Quick Start S3 Bucket Name"
                },
                "QSS3KeyPrefix": {
                    "default": "Quick Start S3 Key Prefix"
                },
                "VPCCIDR": {
                    "default": "VPC CIDR"
                },
                "VPCID": {
                    "default": "VPC ID"
                }
            }
        }
    },
    "Parameters": {
        "DomainAdminPassword": {
            "Description": "Password for the domain admin user. Must be at least 8 characters containing letters, numbers and symbols",
            "Type": "String",
            "MinLength": "8",
            "MaxLength": "32",
            "AllowedPattern": "(?=^.{6,255}$)((?=.*\\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\\d)(?=.*[^A-Za-z0-9])(?=.*[a-z])|(?=.*[^A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z])|(?=.*\\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9]))^.*",
            "NoEcho": "true"
        },
        "DomainDNSName": {
            "Description": "Fully qualified domain name (FQDN) of the forest root domain e.g. example.com",
            "Type": "String",
            "Default": "example.com",
            "MinLength": "2",
            "MaxLength": "255",
            "AllowedPattern": "[a-zA-Z0-9\\-]+\\..+"
        },
        "DomainNetBIOSName": {
            "Description": "NetBIOS name of the domain (upto 15 characters) for users of earlier versions of Windows e.g. EXAMPLE",
            "Type": "String",
            "Default": "example",
            "MinLength": "1",
            "MaxLength": "15",
            "AllowedPattern": "[a-zA-Z0-9\\-]+"
        },
        "ADEdition": {
            "AllowedValues": [
                "Standard",
                "Enterprise"
            ],
            "Default": "Enterprise",
            "Description": "The AWS Microsoft AD edition. Valid values include Standard and Enterprise.",
            "Type": "String"
        },
        "PrivateSubnet1CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.0.0/19",
            "Description": "CIDR block for private subnet 1 located in Availability Zone 1.",
            "Type": "String"
        },
        "PrivateSubnet1ID": {
            "Description": "ID of the private subnet 1 in Availability Zone 1 (e.g., subnet-a0246dcd)",
            "Type": "AWS::EC2::Subnet::Id"
        },
        "PrivateSubnet2CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.32.0/19",
            "Description": "CIDR block for private subnet 2 located in Availability Zone 2.",
            "Type": "String"
        },
        "PrivateSubnet2ID": {
            "Description": "ID of the private subnet 2 in Availability Zone 2 (e.g., subnet-a0246dcd)",
            "Type": "AWS::EC2::Subnet::Id"
        },
        "PublicSubnet1CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.128.0/20",
            "Description": "CIDR Block for the public DMZ subnet 1 located in Availability Zone 1",
            "Type": "String"
        },
        "PublicSubnet2CIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.144.0/20",
            "Description": "CIDR Block for the public DMZ subnet 2 located in Availability Zone 2",
            "Type": "String"
        },
        "QSS3BucketName": {
            "AllowedPattern": "^[0-9a-zA-Z]+([0-9a-zA-Z-]*[0-9a-zA-Z])*$",
            "ConstraintDescription": "Quick Start bucket name can include numbers, lowercase letters, uppercase letters, and hyphens (-). It cannot start or end with a hyphen (-).",
            "Default": "aws-quickstart",
            "Description": "S3 bucket name for the Quick Start assets. Quick Start bucket name can include numbers, lowercase letters, uppercase letters, and hyphens (-). It cannot start or end with a hyphen (-).",
            "Type": "String"
        },
        "QSS3KeyPrefix": {
            "AllowedPattern": "^[0-9a-zA-Z-/]*$",
            "ConstraintDescription": "Quick Start key prefix can include numbers, lowercase letters, uppercase letters, hyphens (-), and forward slash (/).",
            "Default": "quickstart-microsoft-activedirectory/",
            "Description": "S3 key prefix for the Quick Start assets. Quick Start key prefix can include numbers, lowercase letters, uppercase letters, hyphens (-), and forward slash (/).",
            "Type": "String"
        },
        "VPCCIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$",
            "ConstraintDescription": "CIDR block parameter must be in the form x.x.x.x/16-28",
            "Default": "10.0.0.0/16",
            "Description": "CIDR Block for the VPC",
            "Type": "String"
        },
        "VPCID": {
            "Description": "ID of the VPC (e.g., vpc-0343606e)",
            "Type": "AWS::EC2::VPC::Id"
        }
    },
    "Rules": {
        "SubnetsInVPC": {
            "Assertions": [
                {
                    "Assert": {
                        "Fn::EachMemberIn": [
                            {
                                "Fn::ValueOfAll": [
                                    "AWS::EC2::Subnet::Id",
                                    "VpcId"
                                ]
                            },
                            {
                                "Fn::RefAll": "AWS::EC2::VPC::Id"
                            }
                        ]
                    },
                    "AssertDescription": "All subnets must in the VPC"
                }
            ]
        }
    },
    "Resources": {
        "DHCPOptions": {
            "Type": "AWS::EC2::DHCPOptions",
            "DependsOn": "MicrosoftAD",
            "Properties": {
                "DomainName": {
                    "Ref": "DomainDNSName"
                },
                "DomainNameServers": {
                    "Fn::GetAtt": [
                        "MicrosoftAD",
                        "DnsIpAddresses"
                    ]
                },
                "Tags": [
                    {
                        "Key": "Domain",
                        "Value": {
                            "Ref": "DomainDNSName"
                        }
                    }
                ]
            }
        },
        "VPCDHCPOptionsAssociation": {
            "Type": "AWS::EC2::VPCDHCPOptionsAssociation",
            "Properties": {
                "VpcId": {
                    "Ref": "VPCID"
                },
                "DhcpOptionsId": {
                    "Ref": "DHCPOptions"
                }
            }
        },
        "ADAdminSecrets": {
            "Type": "AWS::SecretsManager::Secret",
            "Properties": {
              "Name": { "Fn::Sub": "AdminSecret" },
              "Description": "Admin User Seccrets for Manged AD Quick Start",
              "SecretString": { "Fn::Sub": "{\"username\":\"Admin\",\"password\":\"${DomainAdminPassword}\"}" }
            }
        },
        "MicrosoftAD": {
            "Type": "AWS::DirectoryService::MicrosoftAD",
            "Properties": {
                "Name": {
                    "Ref": "DomainDNSName"
                },
                "Edition" : {
                    "Ref": "ADEdition"
                },
                "ShortName": {
                    "Ref": "DomainNetBIOSName"
                },
                "Password": {
                    "Ref": "DomainAdminPassword"
                },
                "VpcSettings": {
                    "SubnetIds": [
                        {
                            "Ref": "PrivateSubnet1ID"
                        },
                        {
                            "Ref": "PrivateSubnet2ID"
                        }
                    ],
                    "VpcId": {
                        "Ref": "VPCID"
                    }
                }
            }
        },
        "DomainMemberSG": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "GroupDescription": "Domain Members",
                "VpcId": {
                    "Ref": "VPCID"
                },
                "SecurityGroupIngress": [
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "5985",
                        "ToPort": "5985",
                        "CidrIp": {
                            "Ref": "PrivateSubnet1CIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "53",
                        "ToPort": "53",
                        "CidrIp": {
                            "Ref": "PrivateSubnet1CIDR"
                        }
                    },
                    {
                        "IpProtocol": "udp",
                        "FromPort": "53",
                        "ToPort": "53",
                        "CidrIp": {
                            "Ref": "PrivateSubnet1CIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "49152",
                        "ToPort": "65535",
                        "CidrIp": {
                            "Ref": "PrivateSubnet1CIDR"
                        }
                    },
                    {
                        "IpProtocol": "udp",
                        "FromPort": "49152",
                        "ToPort": "65535",
                        "CidrIp": {
                            "Ref": "PrivateSubnet1CIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "5985",
                        "ToPort": "5985",
                        "CidrIp": {
                            "Ref": "PrivateSubnet2CIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "53",
                        "ToPort": "53",
                        "CidrIp": {
                            "Ref": "PrivateSubnet2CIDR"
                        }
                    },
                    {
                        "IpProtocol": "udp",
                        "FromPort": "53",
                        "ToPort": "53",
                        "CidrIp": {
                            "Ref": "PrivateSubnet2CIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "49152",
                        "ToPort": "65535",
                        "CidrIp": {
                            "Ref": "PrivateSubnet2CIDR"
                        }
                    },
                    {
                        "IpProtocol": "udp",
                        "FromPort": "49152",
                        "ToPort": "65535",
                        "CidrIp": {
                            "Ref": "PrivateSubnet2CIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "3389",
                        "ToPort": "3389",
                        "CidrIp": {
                            "Ref": "PublicSubnet1CIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "3389",
                        "ToPort": "3389",
                        "CidrIp": {
                            "Ref": "PublicSubnet2CIDR"
                        }
                    }
                ]
            }
        }
    },
    "Outputs": {
        "ADServer1PrivateIP": {
            "Value": {
                "Fn::Select": [
                    "0",
                    {
                        "Fn::GetAtt": [
                            "MicrosoftAD",
                            "DnsIpAddresses"
                        ]
                    }
                ]
            },
            "Description": "AD Server 1 Private IP Address (this may vary based on Directory Service order of IP addresses)"
        },
        "ADServer2PrivateIP": {
            "Value": {
                "Fn::Select": [
                    "1",
                    {
                        "Fn::GetAtt": [
                            "MicrosoftAD",
                            "DnsIpAddresses"
                        ]
                    }
                ]
            },
            "Description": "AD Server 2 Private IP Address (this may vary based on Directory Service order of IP addresses)"
        },
        "DirectoryID": {
            "Value": {
                "Ref": "MicrosoftAD"
            },
            "Description": "Directory Services ID"
        },        
        "DomainAdmin": {
            "Value": {
                "Fn::Join": [
                    "",
                    [
                        {
                            "Ref": "DomainNetBIOSName"
                        },
                        "\\admin"
                    ]
                ]
            },
            "Description": "Domain administrator account"
        },
        "DomainMemberSGID": {
            "Value": {
                "Ref": "DomainMemberSG"
            },
            "Description": "Domain Member Security Group ID"
        },
        "ADSecretsArn": {
            "Value": {
                "Ref": "ADAdminSecrets"
            },
            "Description": "Managed AD Admin Secrets"
        }
    }
}
```

### Remote Desktop Gateway Bastion taken from [RDGateway Quick start](https://github.com/aws-quickstart/quickstart-microsoft-rdgateway)

```JSON
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "This template is intended to be installed into an existing VPC with two public subnets and an Active Directory domain. It will create an auto-scaling group of RD Gateway instances in the public VPC subnets. **WARNING** This template creates Amazon EC2 Windows instance and related resources. You will be billed for the AWS resources used if you create a stack from this template. QS(0006)",
    "Metadata": {
        "AWS::CloudFormation::Interface": {
            "ParameterGroups": [
                {
                    "Label": {
                        "default": "Network Configuration"
                    },
                    "Parameters": [
                        "VPCID",
                        "PublicSubnet1ID",
                        "PublicSubnet2ID",
                        "RDGWCIDR"
                    ]
                },
                {
                    "Label": {
                        "default": "Amazon EC2 Configuration"
                    },
                    "Parameters": [
                        "RDGWInstanceType",
                        "LatestAmiId"
                    ]
                },
                {
                    "Label": {
                        "default": "Microsoft Active Directory Configuration"
                    },
                    "Parameters": [
                        "DomainDNSName",
                        "DomainNetBIOSName",
                        "DomainMemberSGID",
                        "DomainAdminUser",
                        "DomainAdminPassword"
                    ]
                },
                {
                    "Label": {
                        "default": "Microsoft Remote Desktop Gateway Configuration"
                    },
                    "Parameters": [
                        "NumberOfRDGWHosts"
                    ]
                },
                {
                    "Label": {
                        "default": "AWS Quick Start Configuration"
                    },
                    "Parameters": [
                        "QSS3BucketName",
                        "QSS3KeyPrefix"
                    ]
                }
            ],
            "ParameterLabels": {
                "DomainAdminPassword": {
                    "default": "Domain Admin Password"
                },
                "DomainAdminUser": {
                    "default": "Domain Admin User Name"
                },
                "DomainDNSName": {
                    "default": "Domain DNS Name"
                },
                "DomainMemberSGID": {
                    "default": "Domain Member Security Group ID"
                },
                "DomainNetBIOSName": {
                    "default": "Domain NetBIOS Name"
                },
                "LatestAmiId": {
                    "default": "SSM Parameter to Grab Latest AMI ID"
                },
                "NumberOfRDGWHosts": {
                    "default": "Number of RDGW Hosts"
                },
                "PublicSubnet1ID": {
                    "default": "Public Subnet 1 ID"
                },
                "PublicSubnet2ID": {
                    "default": "Public Subnet 2 ID"
                },
                "QSS3BucketName": {
                    "default": "Quick Start S3 Bucket Name"
                },
                "QSS3KeyPrefix": {
                    "default": "Quick Start S3 Key Prefix"
                },
                "RDGWInstanceType": {
                    "default": "Remote Desktop Gateway Instance Type"
                },
                "RDGWCIDR": {
                    "default": "Allowed Remote Desktop Gateway External Access CIDR"
                },
                "VPCID": {
                    "default": "VPC ID"
                }
            }
        }
    },
    "Parameters": {
        "DomainAdminPassword": {
            "AllowedPattern": "(?=^.{6,255}$)((?=.*\\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\\d)(?=.*[^A-Za-z0-9])(?=.*[a-z])|(?=.*[^A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z])|(?=.*\\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9]))^.*",
            "Description": "Password for the domain admin user. Must be at least 8 characters containing letters, numbers and symbols",
            "MaxLength": "32",
            "MinLength": "8",
            "NoEcho": "true",
            "Type": "String"
        },
        "DomainAdminUser": {
            "AllowedPattern": "[a-zA-Z0-9]*",
            "Default": "StackAdmin",
            "Description": "User name for the Domain Administrator. This is separate from the default \"Administrator\" account",
            "MaxLength": "25",
            "MinLength": "5",
            "Type": "String"
        },
        "DomainDNSName": {
            "Description": "Fully qualified domain name (FQDN) e.g. example.com",
            "Type": "String",
            "Default": "example.com",
            "MinLength": "2",
            "MaxLength": "255",
            "AllowedPattern": "[a-zA-Z0-9\\-]+\\..+"
        },
        "DomainMemberSGID": {
            "Description": "ID of the Domain Member Security Group (e.g., sg-7f16e910)",
            "Type": "AWS::EC2::SecurityGroup::Id"
        },
        "DomainNetBIOSName": {
            "AllowedPattern": "[a-zA-Z0-9\\-]+",
            "Default": "example",
            "Description": "NetBIOS name of the domain (up to 15 characters) for users of earlier versions of Windows e.g. EXAMPLE",
            "MaxLength": "15",
            "MinLength": "1",
            "Type": "String"
        },
        "LatestAmiId": {
            "Type": "AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>",
            "Default": "/aws/service/ami-windows-latest/Windows_Server-2016-English-Full-Base"
        },
        "NumberOfRDGWHosts": {
            "AllowedValues": [
                "1",
                "2",
                "3",
                "4"
            ],
            "Default": "1",
            "Description": "Enter the number of Remote Desktop Gateway hosts to create",
            "Type": "String"
        },
        "PublicSubnet1ID": {
            "Description": "ID of the public subnet 1 that you want to provision the first Remote Desktop Gateway into (e.g., subnet-a0246dcd)",
            "Type": "AWS::EC2::Subnet::Id"
        },
        "PublicSubnet2ID": {
            "Description": "ID of the public subnet 2 you want to provision the second Remote Desktop Gateway into (e.g., subnet-e3246d8e)",
            "Type": "AWS::EC2::Subnet::Id"
        },
        "QSS3BucketName": {
            "AllowedPattern": "^[0-9a-zA-Z]+([0-9a-zA-Z-]*[0-9a-zA-Z])*$",
            "ConstraintDescription": "Quick Start bucket name can include numbers, lowercase letters, uppercase letters, and hyphens (-). It cannot start or end with a hyphen (-).",
            "Default": "aws-quickstart",
            "Description": "S3 bucket name for the Quick Start assets. Quick Start bucket name can include numbers, lowercase letters, uppercase letters, and hyphens (-). It cannot start or end with a hyphen (-).",
            "Type": "String"
        },
        "QSS3KeyPrefix": {
            "AllowedPattern": "^[0-9a-zA-Z-/]*$",
            "ConstraintDescription": "Quick Start key prefix can include numbers, lowercase letters, uppercase letters, hyphens (-), and forward slash (/).",
            "Default": "quickstart-microsoft-rdgateway/",
            "Description": "S3 key prefix for the Quick Start assets. Quick Start key prefix can include numbers, lowercase letters, uppercase letters, hyphens (-), and forward slash (/).",
            "Type": "String"
        },
        "RDGWInstanceType": {
            "Description": "Amazon EC2 instance type for the Remote Desktop Gateway instances",
            "Type": "String",
            "Default": "t2.large",
            "AllowedValues": [
                "t2.large",
                "m3.large",
                "m3.xlarge",
                "m3.2xlarge",
                "m4.large",
                "m4.xlarge",
                "m4.2xlarge",
                "m4.4xlarge",
                "m5.large",
                "m5.xlarge",
                "m5.2xlarge",
                "m5.4xlarge"
            ]
        },
        "RDGWCIDR": {
            "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$",
            "Description": "Allowed CIDR Block for external access to the Remote Desktop Gateways",
            "Type": "String"
        },
        "VPCID": {
            "Description": "ID of the VPC (e.g., vpc-0343606e)",
            "Type": "AWS::EC2::VPC::Id"
        }
    },
    "Rules": {
        "SubnetsInVPC": {
            "Assertions": [
                {
                    "Assert": {
                        "Fn::EachMemberIn": [
                            {
                                "Fn::ValueOfAll": [
                                    "AWS::EC2::Subnet::Id",
                                    "VpcId"
                                ]
                            },
                            {
                                "Fn::RefAll": "AWS::EC2::VPC::Id"
                            }
                        ]
                    },
                    "AssertDescription": "All subnets must in the VPC"
                }
            ]
        },
        "CheckSupportedInstances": {
            "RuleCondition": {
                "Fn::Contains": [
                    [
                        "m4.large",
                        "m4.xlarge",
                        "m4.2xlarge",
                        "m4.4xlarge"
                    ],
                    {
                        "Ref": "RDGWInstanceType"
                    }
                ]
            },
            "Assertions": [
                {
                    "Assert": {
                        "Fn::Not": [
                            {
                                "Fn::Contains": [
                                    [
                                        "eu-west-3"
                                    ],
                                    {
                                        "Ref": "AWS::Region"
                                    }
                                ]
                            }
                        ]
                    },
                    "AssertDescription": "M4 instances are not available in the Paris region"
                }
            ]
        }
    },
    "Conditions": {
        "2RDGWCondition": {
            "Fn::Or": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "NumberOfRDGWHosts"
                        },
                        "2"
                    ]
                },
                {
                    "Condition": "3RDGWCondition"
                },
                {
                    "Condition": "4RDGWCondition"
                }
            ]
        },
        "3RDGWCondition": {
            "Fn::Or": [
                {
                    "Fn::Equals": [
                        {
                            "Ref": "NumberOfRDGWHosts"
                        },
                        "3"
                    ]
                },
                {
                    "Condition": "4RDGWCondition"
                }
            ]
        },
        "4RDGWCondition": {
            "Fn::Equals": [
                {
                    "Ref": "NumberOfRDGWHosts"
                },
                "4"
            ]
        },
        "GovCloudCondition": {
            "Fn::Equals": [
                {
                    "Ref": "AWS::Region"
                },
                "us-gov-west-1"
            ]
        }
    },
    "Resources": {
        "EIP1": {
            "Type": "AWS::EC2::EIP",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "EIP2": {
            "Type": "AWS::EC2::EIP",
            "Condition": "2RDGWCondition",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "EIP3": {
            "Type": "AWS::EC2::EIP",
            "Condition": "3RDGWCondition",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "EIP4": {
            "Type": "AWS::EC2::EIP",
            "Condition": "4RDGWCondition",
            "Properties": {
                "Domain": "vpc"
            }
        },
        "RDGWHostRole": {
            "Type": "AWS::IAM::Role",
            "Properties": {
                "Policies": [
                    {
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Action": [
                                        "s3:GetObject"
                                    ],
                                    "Resource": {
                                        "Fn::Sub": [
                                            "arn:${Partition}:s3:::${QSS3BucketName}/${QSS3KeyPrefix}*",
                                            {
                                                "Partition": {
                                                    "Fn::If": [
                                                        "GovCloudCondition",
                                                        "aws-us-gov",
                                                        "aws"
                                                    ]
                                                }
                                            }
                                        ]
                                    },
                                    "Effect": "Allow"
                                }
                            ]
                        },
                        "PolicyName": "aws-quick-start-s3-policy"
                    },
                    {
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Action": [
                                        "ec2:AssociateAddress",
                                        "ec2:DescribeAddresses"
                                    ],
                                    "Resource": [
                                        "*"
                                    ],
                                    "Effect": "Allow"
                                }
                            ]
                        },
                        "PolicyName": "rdgw-eip-policy"
                    }
                ],
                "Path": "/",
                "AssumeRolePolicyDocument": {
                    "Statement": [
                        {
                            "Action": [
                                "sts:AssumeRole"
                            ],
                            "Principal": {
                                "Service": [
                                    "ec2.amazonaws.com"
                                ]
                            },
                            "Effect": "Allow"
                        }
                    ],
                    "Version": "2012-10-17"
                }
            }
        },
        "RDGWHostProfile": {
            "Type": "AWS::IAM::InstanceProfile",
            "Properties": {
                "Roles": [
                    {
                        "Ref": "RDGWHostRole"
                    }
                ],
                "Path": "/"
            }
        },
        "RDGWAutoScalingGroup": {
            "Type": "AWS::AutoScaling::AutoScalingGroup",
            "Properties": {
                "LaunchConfigurationName": {
                    "Ref": "RDGWLaunchConfiguration"
                },
                "VPCZoneIdentifier": [
                    {
                        "Ref": "PublicSubnet1ID"
                    },
                    {
                        "Ref": "PublicSubnet2ID"
                    }
                ],
                "MinSize": {
                    "Ref": "NumberOfRDGWHosts"
                },
                "MaxSize": {
                    "Ref": "NumberOfRDGWHosts"
                },
                "Cooldown": "300",
                "DesiredCapacity": {
                    "Ref": "NumberOfRDGWHosts"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "RDGW",
                        "PropagateAtLaunch": "true"
                    }
                ]
            },
            "CreationPolicy": {
                "ResourceSignal": {
                    "Count": {
                        "Ref": "NumberOfRDGWHosts"
                    },
                    "Timeout": "PT30M"
                }
            }
        },
        "RDGWLaunchConfiguration": {
            "Type": "AWS::AutoScaling::LaunchConfiguration",
            "Metadata": {
                "AWS::CloudFormation::Authentication": {
                    "S3AccessCreds": {
                        "type": "S3",
                        "roleName": {
                            "Ref": "RDGWHostRole"
                        },
                        "buckets": [
                            {
                                "Ref": "QSS3BucketName"
                            }
                        ]
                    }
                },
                "AWS::CloudFormation::Init": {
                    "configSets": {
                        "config": [
                            "setup",
                            "join",
                            "installRDS",
                            "finalize"
                        ]
                    },
                    "setup": {
                        "files": {
                            "c:\\cfn\\cfn-hup.conf": {
                                "content": {
                                    "Fn::Join": [
                                        "",
                                        [
                                            "[main]\n",
                                            "stack=",
                                            {
                                                "Ref": "AWS::StackName"
                                            },
                                            "\n",
                                            "region=",
                                            {
                                                "Ref": "AWS::Region"
                                            },
                                            "\n"
                                        ]
                                    ]
                                }
                            },
                            "c:\\cfn\\hooks.d\\cfn-auto-reloader.conf": {
                                "content": {
                                    "Fn::Join": [
                                        "",
                                        [
                                            "[cfn-auto-reloader-hook]\n",
                                            "triggers=post.update\n",
                                            "path=Resources.RDGWLaunchConfiguration.Metadata.AWS::CloudFormation::Init\n",
                                            "action=cfn-init.exe -v -c config -s ",
                                            {
                                                "Ref": "AWS::StackId"
                                            },
                                            " -r RDGWLaunchConfiguration",
                                            " --region ",
                                            {
                                                "Ref": "AWS::Region"
                                            },
                                            "\n"
                                        ]
                                    ]
                                }
                            },
                            "C:\\cfn\\scripts\\Unzip-Archive.ps1": {
                                "source": {
                                    "Fn::Sub": [
                                        "https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/scripts/Unzip-Archive.ps1",
                                        {
                                            "QSS3Region": {
                                                "Fn::If": [
                                                    "GovCloudCondition",
                                                    "s3-us-gov-west-1",
                                                    "s3"
                                                ]
                                            }
                                        }
                                    ]
                                },
                                "authentication": "S3AccessCreds"
                            },
                            "C:\\cfn\\modules\\AWSQuickStart.zip": {
                                "source": {
                                    "Fn::Sub": [
                                        "https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/scripts/AWSQuickStart.zip",
                                        {
                                            "QSS3Region": {
                                                "Fn::If": [
                                                    "GovCloudCondition",
                                                    "s3-us-gov-west-1",
                                                    "s3"
                                                ]
                                            }
                                        }
                                    ]
                                },
                                "authentication": "S3AccessCreds"
                            },
                            "C:\\cfn\\scripts\\Join-Domain.ps1": {
                                "source": {
                                    "Fn::Sub": [
                                        "https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/scripts/Join-Domain.ps1",
                                        {
                                            "QSS3Region": {
                                                "Fn::If": [
                                                    "GovCloudCondition",
                                                    "s3-us-gov-west-1",
                                                    "s3"
                                                ]
                                            }
                                        }
                                    ]
                                },
                                "authentication": "S3AccessCreds"
                            },
                            "c:\\cfn\\scripts\\Initialize-RDGW.ps1": {
                                "source": {
                                    "Fn::Sub": [
                                        "https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/scripts/Initialize-RDGW.ps1",
                                        {
                                            "QSS3Region": {
                                                "Fn::If": [
                                                    "GovCloudCondition",
                                                    "s3-us-gov-west-1",
                                                    "s3"
                                                ]
                                            }
                                        }
                                    ]
                                },
                                "authentication": "S3AccessCreds"
                            },
                            "c:\\cfn\\scripts\\Set-EIP.ps1": {
                                "source": {
                                    "Fn::Sub": [
                                        "https://${QSS3BucketName}.${QSS3Region}.amazonaws.com/${QSS3KeyPrefix}/scripts/Set-EIP.ps1",
                                        {
                                            "QSS3Region": {
                                                "Fn::If": [
                                                    "GovCloudCondition",
                                                    "s3-us-gov-west-1",
                                                    "s3"
                                                ]
                                            }
                                        }
                                    ]
                                },
                                "authentication": "S3AccessCreds"
                            }
                        },
                        "services": {
                            "windows": {
                                "cfn-hup": {
                                    "enabled": "true",
                                    "ensureRunning": "true",
                                    "files": [
                                        "c:\\cfn\\cfn-hup.conf",
                                        "c:\\cfn\\hooks.d\\cfn-auto-reloader.conf"
                                    ]
                                }
                            }
                        },
                        "commands": {
                            "a-set-execution-policy": {
                                "command": "powershell.exe -Command \"Set-ExecutionPolicy RemoteSigned -Force\"",
                                "waitAfterCompletion": "0"
                            },
                            "b-unpack-quickstart-module": {
                                "command": "powershell.exe -Command C:\\cfn\\scripts\\Unzip-Archive.ps1 -Source C:\\cfn\\modules\\AWSQuickStart.zip -Destination C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules\\",
                                "waitAfterCompletion": "0"
                            },
                            "c-init-quickstart-module": {
                                "command": {
                                    "Fn::Join": [
                                        "",
                                        [
                                            "powershell.exe -Command \"",
                                            "New-AWSQuickStartResourceSignal -Stack '",
                                            {
                                                "Ref": "AWS::StackName"
                                            },
                                            "' -Resource 'RDGWAutoScalingGroup' -Region '",
                                            {
                                                "Ref": "AWS::Region"
                                            },
                                            "'\""
                                        ]
                                    ]
                                },
                                "waitAfterCompletion": "0"
                            }
                        }
                    },
                    "join": {
                        "commands": {
                            "a-join-domain": {
                                "command": {
                                    "Fn::Join": [
                                        "",
                                        [
                                            "powershell.exe -Command \"C:\\cfn\\scripts\\Join-Domain.ps1 -DomainName '",
                                            {
                                                "Ref": "DomainDNSName"
                                            },
                                            "' -UserName '",
                                            {
                                                "Ref": "DomainNetBIOSName"
                                            },
                                            "\\",
                                            {
                                                "Ref": "DomainAdminUser"
                                            },
                                            "' -Password '",
                                            {
                                                "Ref": "DomainAdminPassword"
                                            },
                                            "'\""
                                        ]
                                    ]
                                },
                                "waitAfterCompletion": "forever"
                            }
                        }
                    },
                    "installRDS": {
                        "commands": {
                            "a-install-rds": {
                                "command": {
                                    "Fn::Join": [
                                        "",
                                        [
                                            "powershell.exe -Command \"Install-WindowsFeature RDS-Gateway,RSAT-RDS-Gateway\""
                                        ]
                                    ]
                                },
                                "waitAfterCompletion": "0"
                            },
                            "b-configure-rdgw": {
                                "command": {
                                    "Fn::Join": [
                                        "",
                                        [
                                            "powershell.exe -ExecutionPolicy RemoteSigned ",
                                            "C:\\cfn\\scripts\\Initialize-RDGW.ps1 -ServerFQDN $($env:COMPUTERNAME + '.",
                                            {
                                                "Ref": "DomainDNSName"
                                            },
                                            "') -DomainNetBiosName ",
                                            {
                                                "Ref": "DomainNetBIOSName"
                                            },
                                            " -GroupName 'domain admins'"
                                        ]
                                    ]
                                },
                                "waitAfterCompletion": "0"
                            },
                            "c-assign-eip": {
                                "command": {
                                    "Fn::Join": [
                                        "",
                                        [
                                            "powershell.exe -ExecutionPolicy RemoteSigned ",
                                            "C:\\cfn\\scripts\\Set-EIP.ps1 -EIPs @('",
                                            {
                                                "Ref": "EIP1"
                                            },
                                            "','",
                                            {
                                                "Fn::If": [
                                                    "2RDGWCondition",
                                                    {
                                                        "Ref": "EIP2"
                                                    },
                                                    "Null"
                                                ]
                                            },
                                            "','",
                                            {
                                                "Fn::If": [
                                                    "3RDGWCondition",
                                                    {
                                                        "Ref": "EIP3"
                                                    },
                                                    "Null"
                                                ]
                                            },
                                            "','",
                                            {
                                                "Fn::If": [
                                                    "4RDGWCondition",
                                                    {
                                                        "Ref": "EIP4"
                                                    },
                                                    "Null"
                                                ]
                                            },
                                            "')"
                                        ]
                                    ]
                                },
                                "waitAfterCompletion": "0"
                            }
                        }
                    },
                    "finalize": {
                        "commands": {
                            "1-signal-success": {
                                "command": "powershell.exe -Command \"Write-AWSQuickStartStatus\"",
                                "waitAfterCompletion": "0"
                            }
                        }
                    }
                }
            },
            "Properties": {
                "ImageId": {
                    "Ref": "LatestAmiId"
                },
                "SecurityGroups": [
                    {
                        "Ref": "RemoteDesktopGatewaySG"
                    },
                    {
                        "Ref": "DomainMemberSGID"
                    }
                ],
                "IamInstanceProfile": {
                    "Ref": "RDGWHostProfile"
                },
                "InstanceType": {
                    "Ref": "RDGWInstanceType"
                },
                "BlockDeviceMappings": [
                    {
                        "DeviceName": "/dev/sda1",
                        "Ebs": {
                            "VolumeSize": "50",
                            "VolumeType": "gp2"
                        }
                    }
                ],
                "UserData": {
                    "Fn::Base64": {
                        "Fn::Join": [
                            "",
                            [
                                "<script>\n",
                                "cfn-init.exe -v -c config -s ",
                                {
                                    "Ref": "AWS::StackId"
                                },
                                " -r RDGWLaunchConfiguration",
                                " --region ",
                                {
                                    "Ref": "AWS::Region"
                                },
                                "\n",
                                "</script>\n"
                            ]
                        ]
                    }
                }
            }
        },
        "RemoteDesktopGatewaySG": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "GroupDescription": "Enable RDP access from the Internet",
                "VpcId": {
                    "Ref": "VPCID"
                },
                "SecurityGroupIngress": [
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "3389",
                        "ToPort": "3389",
                        "CidrIp": {
                            "Ref": "RDGWCIDR"
                        }
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "443",
                        "ToPort": "443",
                        "CidrIp": {
                            "Ref": "RDGWCIDR"
                        }
                    },
                    {
                        "IpProtocol": "udp",
                        "FromPort": "3391",
                        "ToPort": "3391",
                        "CidrIp": {
                            "Ref": "RDGWCIDR"
                        }
                    },
                    {
                        "IpProtocol": "icmp",
                        "FromPort": "-1",
                        "ToPort": "-1",
                        "CidrIp": {
                            "Ref": "RDGWCIDR"
                        }
                    }
                ]
            }
        }
    },
    "Outputs": {
        "EIP1": {
            "Description": "Elastic IP 1 for RDGW",
            "Value": {
                "Ref": "EIP1"
            }
        },
        "EIP2": {
            "Condition": "2RDGWCondition",
            "Description": "Elastic IP 2 for RDGW",
            "Value": {
                "Ref": "EIP2"
            }
        },
        "EIP3": {
            "Condition": "3RDGWCondition",
            "Description": "Elastic IP 3 for RDGW",
            "Value": {
                "Ref": "EIP3"
            }
        },
        "EIP4": {
            "Condition": "4RDGWCondition",
            "Description": "Elastic IP 4 for RDGW",
            "Value": {
                "Ref": "EIP4"
            }
        },
        "RemoteDesktopGatewaySGID": {
            "Value": {
                "Ref": "RemoteDesktopGatewaySG"
            },
            "Description": "Remote Desktop Gateway Security Group ID"
        }
    }
}
```

### Amazon FSx Template

```YAML
Description: >-
  This template deploys an FSx for Windows Servers for the CA POC
Parameters:
  ADId:
    Description: "Id of the target Managed Active Directory"
    Type: String
    Default: ""
  PrivateSubnet1:
    Description: Subnet to be used for the Directory
    Type: String
Resources:
  MainFSx:
    Type: 'AWS::FSx::FileSystem'
    Properties:
      FileSystemType: WINDOWS
      StorageCapacity: 300
      SubnetIds: 
       - !Ref PrivateSubnet1
      WindowsConfiguration:
        ActiveDirectoryId: !Ref ADId
        ThroughputCapacity: 8
        AutomaticBackupRetentionDays: 2
        CopyTagsToBackups: true
```

### Migration Instances Template

```YAML
Description: "Deploy Single EC2 Linux Instance"
Parameters:
  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
    Default: "/aws/service/ami-windows-latest/Windows_Server-2016-English-Full-Base"
  SubnetID:
    Description: ID of a Subnet.
    Type: AWS::EC2::Subnet::Id
  SecretsARN:
    Description: ARN for Secrets in Secrets Manager
    Type: String
  SourceLocation:
    Description : The CIDR IP address range that can be used to RDP to the EC2 instances
    Type: String
    MinLength: 9
    MaxLength: 18
    Default: 0.0.0.0/0
    AllowedPattern: "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})"
    ConstraintDescription: must be a valid IP CIDR range of the form x.x.x.x/x.
  VPCID:
    Description: ID of the target VPC (e.g., vpc-0343606e).
    Type: AWS::EC2::VPC::Id
Resources:
  RDPServerSG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: RDP Access Group
      VpcId: !Ref 'VPCID'
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 3389
        ToPort: 3389
        CidrIp: !Ref SourceLocation
  SSMInstanceRole: 
    Type : AWS::IAM::Role
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
              - Effect: Allow
                Action:
                  - secretsmanager:GetSecretValue
                  - secretsmanager:DescribeSecret
                Resource: 
                  - !Ref 'SecretsARN'
          PolicyName: QS-MSSQL-SSM
      Path: /
      ManagedPolicyArns:
        - !Sub 'arn:${AWS::Partition}:iam::aws:policy/AmazonSSMManagedInstanceCore'
        - !Sub 'arn:${AWS::Partition}:iam::aws:policy/CloudWatchAgentServerPolicy'
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
        - Effect: "Allow"
          Principal:
            Service:
            - "ec2.amazonaws.com"
            - "ssm.amazonaws.com"
          Action: "sts:AssumeRole"
  SSMInstanceProfile:
    Type: "AWS::IAM::InstanceProfile"
    Properties:
      Roles:
      - !Ref SSMInstanceRole
  CE1EC2Instance:
    Type: "AWS::EC2::Instance"
    Properties:
      ImageId: !Ref LatestAmiId
      InstanceType: "m5.large"
      IamInstanceProfile: !Ref SSMInstanceProfile
      NetworkInterfaces:
        - DeleteOnTermination: true
          DeviceIndex: '0'
          SubnetId: !Ref 'SubnetID'
          GroupSet:
            - !Ref RDPServerSG
      Tags:
      - Key: "Name"
        Value: "CEMigration1"
  CE2EC2Instance:
    Type: "AWS::EC2::Instance"
    Properties:
      ImageId: !Ref LatestAmiId
      InstanceType: "m5.large"
      IamInstanceProfile: !Ref SSMInstanceProfile
      NetworkInterfaces:
        - DeleteOnTermination: true
          DeviceIndex: '0'
          SubnetId: !Ref 'SubnetID'
          GroupSet:
            - !Ref RDPServerSG
      Tags:
      - Key: "Name"
        Value: "CEMigration2"
Outputs:
  SSMInstanceProfileName:
    Description: Name of the Instance Profile
    Value: !Ref 'SSMInstanceProfile'
  EC1PrivateIP:
    Value: !GetAtt 'CE1EC2Instance.PrivateIp'
    Description: IP for Migration EC2 Instance 1
  EC2PrivateIP:
    Value: !GetAtt 'CE2EC2Instance.PrivateIp'
    Description: IP for Migration EC2 Instance 2
```

### DMS Workshop Template

```YAML
AWSTemplateFormatVersion: '2010-09-09'
Description: CloudFormation Template for AWS Database Migration Workshop.
Metadata: 
  AWS::CloudFormation::Interface: 
    ParameterGroups: 
      -
        Label:
          default: "Database Migration Workshop Lab Environment"
        Parameters:
          - LabType
      - 
        Label: 
          default: "Amazon EC2 Configuration"
        Parameters:
          - EC2ServerInstanceType
      - 
        Label: 
          default: "Target Amazon RDS Database Configuration"
        Parameters:
          - RDSInstanceType           
      - 
        Label: 
          default: "Network Configuration"
        Parameters: 
          - VpcCIDR
Mappings:
  RegionMap:
    us-east-1:
      "DMSAMI" : "ami-077a6363df8e6b81a" # Virginia - Updated July 09, 2019
    us-east-2:
      "DMSAMI" : "ami-0b2cd90e595b4fbdf" # Ohio - Updated July 09, 2019
    us-west-2:
      "DMSAMI" : "ami-08ad3b503e5fbda86" # Oregon - Updated July 09, 2019
    ap-south-1:
       "DMSAMI" : "ami-084b98d08e529a7ce" # Mumbai - Updated July 09, 2019
    ap-northeast-2:
       "DMSAMI" : "ami-0cbd98d92366c727e" # Seoul - Updated July 09, 2019
    ap-southeast-1:
      "DMSAMI" : "ami-0f6fb229f36616672" # Singapore - Updated July 09, 2019
    ap-southeast-2:
      "DMSAMI" : "ami-00795035d4f33fb59" # Sydney - Updated July 09, 2019
    ap-northeast-1:
      "DMSAMI" : "ami-00f8c0f2252af1b2f" # Tokyo - Updated July 09, 2019
    eu-central-1:
      "DMSAMI" : "ami-03647cb2150df12c9" # Frankfurt - Updated July 09, 2019
    eu-west-1:
      "DMSAMI" : "ami-08a343117001e9940" # Ireland - Updated July 09, 2019
    eu-west-2:
      "DMSAMI" : "ami-05649ae0708fb839e" # London - Updated July 09, 2019
    eu-west-3:
      "DMSAMI" : "ami-0fbb5f624929600ab" # Paris - Updated July 09, 2019
    eu-north-1:
      "DMSAMI" : "ami-0364d42f436f62276" # Stockholm - Updated July 09, 
    sa-east-1:
      "DMSAMI" : "ami-0101d292d5e2b1ab9" # Sao Paulo - Updated July 09, 2019
  OracleEngineVersion: 
    us-east-1: 
      "ver": "12.1.0.2.v6" # Virginia
    us-east-2: 
      "ver": "12.1.0.2.v6" # Ohio
    us-west-2: 
      "ver": "12.1.0.2.v6" # Oregon
    ap-south-1: 
      "ver": "12.1.0.2.v6" # Mumbai
    ap-northeast-2: 
      "ver": "12.1.0.2.v6" # Seoul
    ap-southeast-1: 
      "ver": "12.1.0.2.v6" # Singapore
    ap-southeast-2: 
      "ver": "12.1.0.2.v6" # Sydney
    ap-northeast-1: 
      "ver": "12.1.0.2.v6" # Tokyo
    eu-central-1: 
      "ver": "12.1.0.2.v6" # Frankfurt
    eu-west-1: 
      "ver": "12.1.0.2.v6" # Ireland
    eu-west-2:
      "ver": "12.1.0.2.v6" # London
    eu-west-3:
      "ver": "12.1.0.2.v6" # Paris
    eu-north-1: 
      "ver": "12.1.0.2.v6" # Stockholm
    sa-east-1: 
      "ver": "12.1.0.2.v6" # Sao Paulo
  OracleSnapshotId: 
    us-east-1: 
      "snapid" : "arn:aws:rds:us-east-1:833997227572:snapshot:dms-lab-oracle-source-snapshot01" # Virginia
    us-east-2: 
      "snapid" : "arn:aws:rds:us-east-2:833997227572:snapshot:dms-lab-oracle-source-us-east-2-snapshot01" # Ohio
    us-west-2: 
      "snapid" : "arn:aws:rds:us-west-2:833997227572:snapshot:dms-lab-oracle-source-us-west-2-snapshot01" # Oregon
    ap-south-1:
      "snapid" : "arn:aws:rds:ap-south-1:833997227572:snapshot:dms-lab-oracle-source-ap-south-1-snapshot01" # Mumbai
    ap-northeast-2:
      "snapid" : "arn:aws:rds:ap-northeast-2:833997227572:snapshot:dms-lab-oracle-source-ap-northeast-2-snapshot01" # Seoul 
    ap-southeast-1:
      "snapid" : "arn:aws:rds:ap-southeast-1:833997227572:snapshot:dms-lab-oracle-source-ap-southeast-1-snapshot01" # Singapore
    ap-southeast-2:
      "snapid" : "arn:aws:rds:ap-southeast-2:833997227572:snapshot:dms-lab-oracle-source-ap-southeast-2-snapshot01" # Sydney 
    ap-northeast-1:
      "snapid" : "arn:aws:rds:ap-northeast-1:833997227572:snapshot:dms-lab-oracle-source-ap-northeast-1-snapshot01" # Tokyo
    eu-central-1: 
      "snapid" : "arn:aws:rds:eu-central-1:833997227572:snapshot:dms-lab-oracle-source-eu-central-1-snapshot01" # Frankfurt
    eu-west-1:
      "snapid" : "arn:aws:rds:eu-west-1:833997227572:snapshot:dms-lab-oracle-source-eu-west-1-snapshot01" # Ireland
    eu-west-2:
      "snapid" : "arn:aws:rds:eu-west-2:833997227572:snapshot:dms-lab-oracle-source-snapshot" # Paris
    eu-west-3:
      "snapid" : "arn:aws:rds:eu-west-3:833997227572:snapshot:dms-lab-oracle-source-snapshot" # Paris
    eu-north-1:
      "snapid" : "arn:aws:rds:eu-north-1:833997227572:snapshot:dms-lab-oracle-source-snapshot" # Stockholm
    sa-east-1:
      "snapid" : "arn:aws:rds:sa-east-1:833997227572:snapshot:dms-lab-oracle-source-snapshot" # Sao Paulo 
Parameters:
  LabType: 
    Description: 'Select your Database Migration lab:'
    Type: String
    Default: 'Microsoft SQL Server to Amazon RDS SQL Server'
  VpcCIDR:
    Description: Enter the VPC CIDR range in the form x.x.x.x/16
    Type: String
    MinLength: 9
    MaxLength: 18
    AllowedPattern: "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})"
    ConstraintDescription: Must be a valid CIDR range in the form x.x.x.x/16
    Default: 10.20.0.0/16
  EC2ServerInstanceType:
    Description: Amazon EC2 Instance Type
    Type: String
    Default: m5.2xlarge
    AllowedValues:
      - m5.large
      - m5.xlarge
      - m5.2xlarge
      - m5.4xlarge
      - m5.8xlarge
      - m5a.large
      - m5a.xlarge
      - m5a.2xlarge
      - m5a.4xlarge
      - m5a.8xlarge
      - r5a.large
      - r5a.xlarge
      - r5a.2xlarge
      - r5a.4xlarge
      - r5a.8xlarge
      - r5.large
      - r5.xlarge
      - r5.2xlarge
      - r5.4xlarge
      - r5.8xlarge
    ConstraintDescription: Must be a valid EC2 instance type. 
  RDSInstanceType:
    Description: Amazon RDS Aurora Instance Type
    Type: String
    Default: db.r4.2xlarge
    AllowedValues:
      - db.r4.large
      - db.r4.xlarge
      - db.r4.2xlarge
      - db.r4.4xlarge
      - db.r4.8xlarge
      - db.r4.16xlarge
    ConstraintDescription: Must be a valid Amazon RDS instance type.
  Subnet1:
    Description: 'ID of the private subnet 1 in Availability Zone 1 (e.g., subnet-a0246dcd)'
    Type: "AWS::EC2::Subnet::Id"
  Subnet2:
    Description: 'ID of the private subnet 1 in Availability Zone 1 (e.g., subnet-a0246dcd)'
    Type: "AWS::EC2::Subnet::Id"
  VPCID:
    Description: ID of the target VPC (e.g., vpc-0343606e).
    Type: AWS::EC2::VPC::Id
  SSMInstanceProfile:
    Description: Instance Profile Name
    Type: String
Conditions: 
  Create-SQLServer-to-AuroraMySQL-Environment: !Equals [ !Ref LabType, 'Microsoft SQL Server to Amazon Aurora (MySQL)' ]
  Create-SQLServer-to-RDSSQLServer-Environment: !Equals [ !Ref LabType, 'Microsoft SQL Server to Amazon RDS SQL Server' ]
  Create-Oracle-to-AuroraPostgreSQL-Environment: !Equals [ !Ref LabType, 'Oracle to Amazon Aurora (PostgreSQL)' ]
  Create-Oracle-to-RDSOracle-Environment: !Equals [ !Ref LabType, 'Oracle to Amazon RDS Oracle' ]
  Create-Oracle-Environment: !Or [!Equals [ !Ref LabType, 'Oracle to Amazon Aurora (PostgreSQL)'], !Equals [ !Ref LabType, 'Oracle to Amazon RDS Oracle'] ] 
Resources:
  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: Subnets available for the DMS Lab 
      SubnetIds:
      - Ref: Subnet1
      - Ref: Subnet2
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref EC2ServerInstanceType
      IamInstanceProfile: !Ref SSMInstanceProfile
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - EC2Instance
      BlockDeviceMappings:
      - DeviceName: "/dev/sda1"
        Ebs:
          DeleteOnTermination: 'true'
          Iops: '5000'
          VolumeSize: '250'
          VolumeType: io1
      ImageId: 
        Fn::FindInMap:
        - RegionMap
        - !Ref AWS::Region
        - DMSAMI
      NetworkInterfaces:
      - AssociatePublicIpAddress: 'true'
        DeleteOnTermination: 'true'
        DeviceIndex: 0
        SubnetId: !Ref Subnet2
        GroupSet:
        - Ref: InstanceSecurityGroup
  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - InstanceSecurityGroup
      GroupDescription: Enable RDP access via port 3389
      VpcId: !Ref VPCID
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: '3389'
        ToPort: '3389'
        CidrIp: 0.0.0.0/0
        Description: Allows RDP access to EC2 Instance
      - IpProtocol: tcp
        FromPort: '1521'
        ToPort: '1521'
        CidrIp: !Ref VpcCIDR
        Description: Allows Amazon RDS Oracle Access
      - IpProtocol: tcp
        FromPort: '5432'
        ToPort: '5432'
        CidrIp: !Ref VpcCIDR
        Description: Allows Amazon RDS Aurora (PostgreSQL) Access
      - IpProtocol: tcp
        FromPort: '1433'
        ToPort: '1433'
        CidrIp: !Ref VpcCIDR
        Description: Allows SQL Server Access
      - IpProtocol: tcp
        FromPort: '3306'
        ToPort: '3306'
        CidrIp: !Ref VpcCIDR 
        Description: Allows Amazon RDS Aurora (MySQL) Access
  SourceOracleDB: 
    Condition: Create-Oracle-Environment
    Type: AWS::RDS::DBInstance  
    Properties: 
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - SourceOracleDB  
      DBName: 'OracleDB'
      AllocatedStorage: 100
      MasterUsername: 'dbmaster'
      MasterUserPassword: 'dbmaster123'
      DBInstanceClass: 'db.r5.2xlarge'
      Engine: oracle-ee
      EngineVersion: 
        Fn::FindInMap:
          - OracleEngineVersion
          - !Ref AWS::Region
          - ver
      LicenseModel: bring-your-own-license
      PubliclyAccessible: false
      AvailabilityZone: 'ca-central-1b'
      MultiAZ: false
      DBSubnetGroupName:
        Ref: DBSubnetGroup
      VPCSecurityGroups:
        - Fn::GetAtt:
          - OracleSourceSecurityGroup
          - GroupId
      DBSnapshotIdentifier: 
        Fn::FindInMap: 
          - OracleSnapshotId
          - !Ref AWS::Region
          - snapid
      StorageType: gp2
      DBInstanceIdentifier:
        Fn::Join:
        - "-"
        - - Ref: AWS::StackName
          - SourceOracleDB
  OracleSourceSecurityGroup:
    Condition: Create-Oracle-Environment
    Type: AWS::EC2::SecurityGroup
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - OracleSourceSecurityGroup
      GroupDescription: Security group for Source Oracle Instance.
      VpcId: !Ref VPCID
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: '1521'
        ToPort: '1521'
        CidrIp: !Ref VpcCIDR
        Description: Allows Amazon RDS Oracle Access
  RDSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - RDSSecurityGroup
      VpcId: !Ref VPCID
      GroupDescription: Amazon Aurora RDS Security Group.
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: '5432'
        ToPort: '5432'
        CidrIp: !Ref VpcCIDR
        Description: Allows Amazon RDS Aurora (PostgreSQL) Access
      - IpProtocol: tcp
        FromPort: '3306'
        ToPort: '3306'
        CidrIp: !Ref VpcCIDR
        Description: Allows Amazon RDS Aurora (MySQL) Access
      - IpProtocol: tcp
        FromPort: '1433'
        ToPort: '1433'
        CidrIp: !Ref VpcCIDR
        Description: Allows Microsoft SQL Server Access
      - IpProtocol: tcp
        FromPort: '1521'
        ToPort: '1521'
        CidrIp: !Ref VpcCIDR
        Description: Allows Oracle Access
  AuroraPostgresqlCluster:
    Condition: Create-Oracle-to-AuroraPostgreSQL-Environment
    Type: AWS::RDS::DBCluster
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - AuroraPostgresqlCluster
      DBSubnetGroupName:
        Ref: DBSubnetGroup
      VpcSecurityGroupIds:
      - Fn::GetAtt:
        - RDSSecurityGroup
        - GroupId
      Engine: aurora-postgresql
      EngineVersion: '9.6'
      DatabaseName: 'AuroraDB'
      DBClusterParameterGroupName: default.aurora-postgresql9.6
      MasterUsername: 'dbmaster'
      MasterUserPassword: 'dbmaster123'
      Port: '5432'
      BackupRetentionPeriod: '7'
    DependsOn: RDSSecurityGroup
  AuroraPostgresqlParameterGroup:
    Condition: Create-Oracle-to-AuroraPostgreSQL-Environment
    Type: AWS::RDS::DBParameterGroup
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - AuroraPostgresqlParameterGroup
      Description: Aurora PostgreSQL DBParameterGroup
      Family: aurora-postgresql9.6
      Parameters:
        shared_preload_libraries: pg_stat_statements
  AuroraPostgresqlInstance:
    Condition: Create-Oracle-to-AuroraPostgreSQL-Environment
    Type: AWS::RDS::DBInstance
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - AuroraPostgresqlInstance
      DBClusterIdentifier:
        Ref: AuroraPostgresqlCluster
      DBInstanceIdentifier:
        Fn::Join:
        - "-"
        - - Ref: AWS::StackName
          - AuroraPostgreSQLInstance
      Engine: aurora-postgresql
      EngineVersion: '9.6'
      DBParameterGroupName:
        Ref: AuroraPostgresqlParameterGroup
      DBClusterIdentifier:
        Ref: AuroraPostgresqlCluster
      DBSubnetGroupName:
        Ref: DBSubnetGroup
      AutoMinorVersionUpgrade: 'true'
      CopyTagsToSnapshot: 'true'
      DBInstanceClass: !Ref RDSInstanceType
      PubliclyAccessible: 'false'
  AuroraMySQLCluster:
    Condition: Create-SQLServer-to-AuroraMySQL-Environment
    Type: AWS::RDS::DBCluster
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - AuroraMySQLCluster
      DBSubnetGroupName:
        Ref: DBSubnetGroup
      VpcSecurityGroupIds:
      - Fn::GetAtt:
        - RDSSecurityGroup
        - GroupId
      DatabaseName: AuroraMySQL
      Engine: aurora
      MasterUsername: awssct
      MasterUserPassword: Password1
    DependsOn: RDSSecurityGroup 
  AuroraMySQLInstance:
    Condition: Create-SQLServer-to-AuroraMySQL-Environment
    Type: AWS::RDS::DBInstance
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - AuroraMySQLInstance
      DBClusterIdentifier:
        Ref: AuroraMySQLCluster
      DBInstanceIdentifier:
        Fn::Join:
        - "-"
        - - Ref: AWS::StackName
          - AuroraMySQLInstance
      DBSubnetGroupName:
        Ref: DBSubnetGroup
      DBInstanceClass: !Ref RDSInstanceType
      Engine: aurora
      EngineVersion: 5.6.10a
      LicenseModel: general-public-license
      PubliclyAccessible: 'false'
  TargetSQLServer:
    Condition: Create-SQLServer-to-RDSSQLServer-Environment
    Type: AWS::RDS::DBInstance
    Properties:
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - AuroraMySQLInstance
      DBSubnetGroupName:
        Ref: DBSubnetGroup
      VPCSecurityGroups:
      - Fn::GetAtt:
        - RDSSecurityGroup
        - GroupId
      DBInstanceIdentifier:
        Fn::Join:
        - "-"
        - - Ref: AWS::StackName
          - TargetSQLServer
      LicenseModel: license-included
      Engine: sqlserver-se
      EngineVersion: 14.00.3049.1.v1
      DBInstanceClass: !Ref RDSInstanceType
      AllocatedStorage: '250'
      Iops: '5000'
      MasterUsername: awssct
      MasterUserPassword: Password1
      PubliclyAccessible: 'false'
      BackupRetentionPeriod: '0'
    DependsOn: RDSSecurityGroup
  TargetOracleDB: 
    Condition: Create-Oracle-to-RDSOracle-Environment
    Type: AWS::RDS::DBInstance  
    Properties: 
      Tags:
      - Key: Name
        Value:
          Fn::Join:
          - "-"
          - - Ref: AWS::StackName
            - TargetOracleDB  
      DBName: 'TargetDB'
      AllocatedStorage: 100
      MasterUsername: 'dbmaster'
      MasterUserPassword: 'dbmaster123'
      DBInstanceClass: 'db.r5.2xlarge'
      Engine: oracle-ee
      EngineVersion: 
        Fn::FindInMap:
          - OracleEngineVersion
          - !Ref AWS::Region
          - ver
      LicenseModel: bring-your-own-license
      PubliclyAccessible: false
      AvailabilityZone: 'ca-central-1b'
      MultiAZ: false
      DBSubnetGroupName:
        Ref: DBSubnetGroup
      VPCSecurityGroups:
        - Fn::GetAtt:
          - RDSSecurityGroup
          - GroupId
      StorageType: gp2
      DBInstanceIdentifier:
        Fn::Join:
        - "-"
        - - Ref: AWS::StackName
          - TargetOracleDB
Outputs:
  SourceEC2PublicDNS:
    Description: Public DNS enpoint for the EC2 instance
    Value:
      Fn::GetAtt:
      - EC2Instance
      - PublicDnsName
  SourceEC2PrivateDNS:
    Description: Private DNS endpoint for the EC2 instance
    Value:
      Fn::GetAtt:
      - EC2Instance
      - PrivateDnsName
  SourceOracleEndpoint:
    Condition: Create-Oracle-Environment
    Description: Source Oracle RDS Endpoint
    Value:
      Fn::GetAtt:
      - SourceOracleDB
      - Endpoint.Address
  TargetAuroraPostgreSQLEndpoint:
    Condition: Create-Oracle-to-AuroraPostgreSQL-Environment
    Description: Target Aurora (PostgreSQL) Database Endpoint
    Value:
      Fn::GetAtt:
      - AuroraPostgresqlCluster
      - Endpoint.Address
  TargetAuroraMySQLEndpoint:
    Condition: Create-SQLServer-to-AuroraMySQL-Environment
    Description: Target Aurora (MySQL) Database Endpoint
    Value:
      Fn::GetAtt:
      - AuroraMySQLInstance
      - Endpoint.Address
  TargetSQLServerEndpoint:
    Condition: Create-SQLServer-to-RDSSQLServer-Environment
    Description: Target MS SQL Server RDS Endpoint
    Value:
      Fn::GetAtt:
      - TargetSQLServer
      - Endpoint.Address  
  TargetOracleEndpoint:
    Condition: Create-Oracle-to-RDSOracle-Environment
    Description: Target Oracle RDS Instance Endpoint
    Value:
      Fn::GetAtt:
      - TargetOracleDB
      - Endpoint.Address
```