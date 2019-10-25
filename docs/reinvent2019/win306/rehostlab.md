# **Re-Host Lab using CloudEndure**

In this lab we will migrate two Windows instances that have been deployed into our lab environment. This is an example of re-hosting, we will not be making any changes to the instances but migrating them as is. This demonstrates how you can migrate on-prem workloads to AWS making minimal changes. 

### **The Migration Life Cycle**
The next diagram shows the migration life cycle for CloudEndure. 

![](/assets/images/WIN306/TheMigrationLifeCycle.png)

### **The Migration Process Workflow**

In this lab we will follow this process flow. This would be similar to the process you would follow for your own migrations. 

1. Install the CloudEndure Agent on the Source machine.
2. Start replication if installed with the --no-replication flag.
3. Wait until Initial Sync is finished.
    - When we reach this step we will move on to the re-platform lab, and return once replication is complete
4. Launch a Target machine in Test Mode.
5. Perform acceptance tests on the machine, once the Target machine is tested successfully, delete it.
6. Wait for the Cutover window.
7. Confirm that the Lag is None.
8. Stop all operational services on the Source machine.
9. Launch a Target machine in Cutover Mode.
10. Confirm that the Target machine was launched successfully.
11. Decommission the Source machine.


### **Getting started**
To get started, let's go over to the [registration](https://migration-register.cloudendure.com/) page for CloudEndure and sign up for a CloudEndure Account.  CloudEndure Migration is provided at no cost for customers and partners migrating workloads into AWS.Each agent allows for 90 days of use from the time of CloudEndure agent installation, after which the source machine will stop replicating and a new target machine cannot be launched.

![](/assets/images/WIN306/CERegistration.jpg)

1. Once CloudEndure registration is complete, login through [https://console.cloudendure.com](https://console.cloudendure.com/) with your **username (email)** and **password**. 

![](/assets/images/WIN306/CloudEndureConsole.png)

2. Once Logged in click on **+** to **Create a New Project**

![](/assets/images/WIN306/CENewProject.png)

3. On the **Create New Project** dialog box, set the following, then click **CREATE PROJECT**.
    * **Project name:** Enter a unique name for the Project. The name can contain up to 255 characters.
    * **Project type:** Select either Disaster Recovery or Migration.
    * **Target cloud:** CloudEndure exclusively utilizes the AWS cloud as a Target infrastructure.
    * **License:** Select a License Package to associate with your Project.

![](/assets/images/WIN306/CreateNewProject.png)

4. You will receive a message stating that your **Project is not set up** until you provide credentials and configure its Replication Settings. Click **CONTINUE** to dismiss the message.

![](/assets/images/WIN306/ProjectSetup.png)

To allow CloudEndure to connect to your AWS account for the purpose of replicating your Source machines to an AWS Target infrastructure, you need to generate AWS credentials and enter them into the CloudEndure User Console. These credentials consist of your **Access key ID** and a **Secret access key**.

![](/assets/images/WIN306/AWSCredentials.png)

### **Creating an IAM Policy for CloudEndure**

To generate the required AWS credentials to use with the CloudEndure User Console, you need to create at least one AWS Identity and Access Management (IAM) user, and assign the proper permission policy to this user. You will obtain an Access key ID and a Secret access key, which are the credentials you need to enter into the CloudEndure User Console.

1. Open another tab and Let's jump into the AWS Console. Once there click on **Services** and then navigate to **Security, Identity & Compliance** and Selecy **IAM**.

![](/assets/images/WIN306/IAMConsole.jpg)

2. On the **Policies** page, click the **Create policy** button.

![](/assets/images/WIN306/CreateIAMPolicy.png)

3. On the Create Policy page, click the **JSON** tab. Copy the policy code in the next code block and paste the copied code into the JSON field. Paste the code over any text that currently exists in the field. Click on **Review policy** at the bottom right of the page.

![](/assets/images/WIN306/ReviewPolicy.png)

```JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "arn:aws:ec2:*:*:*/*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "RunInstances"
        }
      }
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "arn:aws:ec2:*:*:*/*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "CreateVolume"
        }
      }
    },
    {
      "Sid": "VisualEditor2",
      "Effect": "Allow",
      "Action": [
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DetachVolume",
        "ec2:AttachVolume",
        "ec2:DeleteVolume",
        "ec2:TerminateInstances",
        "ec2:StartInstances",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:StopInstances"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:dhcp-options/*",
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:security-group/*"
      ],
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/Name": "CloudEndure*"
        }
      }
    },
    {
      "Sid": "VisualEditor3",
      "Effect": "Allow",
      "Action": [
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DetachVolume",
        "ec2:AttachVolume",
        "ec2:DeleteVolume",
        "ec2:TerminateInstances",
        "ec2:StartInstances",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:StopInstances"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:dhcp-options/*",
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:security-group/*"
      ],
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/CloudEndure creation time": "*"
        }
      }
    },
    {
      "Sid": "VisualEditor4",
      "Effect": "Allow",
      "Action": [
        "ec2:DisassociateAddress",
        "ec2:CreateDhcpOptions",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DeregisterImage",
        "ec2:DeleteSubnet",
        "ec2:DeleteSnapshot",
        "ec2:ModifyVolumeAttribute",
        "ec2:CreateVpc",
        "ec2:AttachInternetGateway",
        "ec2:GetConsoleScreenshot",
        "ec2:GetConsoleOutput",
        "elasticloadbalancing:DescribeLoadBalancers",
        "ec2:CreateRoute",
        "ec2:CreateInternetGateway",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:ModifyVpcAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ReleaseAddress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AssociateDhcpOptions",
        "ec2:ImportKeyPair",
        "ec2:CreateTags",
        "ec2:RegisterImage",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:CreateRouteTable",
        "ec2:DetachInternetGateway",
        "iam:ListInstanceProfiles",
        "ec2:AllocateAddress",
        "ec2:ReplaceNetworkAclAssociation",
        "ec2:CreateVolume",
        "kms:ListKeys",
        "ec2:Describe*",
        "ec2:DeleteVpc",
        "iam:GetUser",
        "ec2:CreateSubnet",
        "ec2:AssociateAddress",
        "ec2:DeleteKeyPair",
        "ec2:CreateNetworkAclEntry"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VisualEditor5",
      "Effect": "Allow",
      "Action": [
        "ec2:RevokeSecurityGroupIngress",
        "mgh:CreateProgressUpdateStream",
        "kms:Decrypt",
        "kms:Encrypt",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DeleteDhcpOptions",
        "ec2:RunInstances",
        "kms:DescribeKey",
        "kms:CreateGrant",
        "ec2:DeleteNetworkAclEntry",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ],
      "Resource": [
        "arn:aws:mgh:*:*:progressUpdateStream/*",
        "arn:aws:ec2:*:*:subnet/*",
        "arn:aws:ec2:*:*:key-pair/*",
        "arn:aws:ec2:*:*:dhcp-options/*",
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*:*:network-acl/*",
        "arn:aws:ec2:*:*:placement-group/*",
        "arn:aws:ec2:*:*:vpc/*",
        "arn:aws:ec2:*:*:network-interface/*",
        "arn:aws:ec2:*::image/*",
        "arn:aws:ec2:*:*:snapshot/*",
        "arn:aws:kms:*:*:key/*"
      ]
    },
    {
      "Sid": "VisualEditor6",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags",
        "mgh:ImportMigrationTask",
        "mgh:AssociateCreatedArtifact",
        "mgh:NotifyMigrationTaskState",
        "mgh:DisassociateCreatedArtifact",
        "mgh:PutResourceAttributes"
      ],
      "Resource": [
        "arn:aws:mgh:*:*:progressUpdateStream/*/migrationTask/*",
        "arn:aws:ec2:*:*:subnet/*",
        "arn:aws:ec2:*::network-interface/*",
        "arn:aws:ec2:*:*:dhcp-options/*",
        "arn:aws:ec2:*::snapshot/*",
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*::image/*"
      ]
    },
    {
      "Sid": "VisualEditor7",
      "Effect": "Allow",
      "Action": "ec2:Delete*",
      "Resource": [
        "arn:aws:ec2:*:*:route-table/*",
        "arn:aws:ec2:*:*:dhcp-options/*",
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*:*:internet-gateway/*"
      ],
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/Name": "CloudEndure*"
        }
      }
    },
    {
      "Sid": "VisualEditor8",
      "Effect": "Allow",
      "Action": "ec2:Delete*",
      "Resource": [
        "arn:aws:ec2:*:*:route-table/*",
        "arn:aws:ec2:*:*:dhcp-options/*",
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*:*:internet-gateway/*"
      ],
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/CloudEndure creation time": "*"
        }
      }
    }
  ]
}
```
4. On the Review policy page, enter a name for the new CloudEndure policy in the **Name** field. Enter an optional description in the **Description** field.

5. Click the **Create policy** button at the bottom right of the page.

![](/assets/images/WIN306/CreatePolicy.png)

6. You will be redirected back to the main Policies page and a confirmation stating that your new policy has been created will appear at the top of the page.

![](/assets/images/WIN306/PolicyCreatedSuccessfully.png)

### **Creating an IAM User for CloudEndure**

After creating an AWS policy which is based on CloudEndure's pre-defined policy, you will need to create a new IAM user and to attach the new policy to this user. You also need to provide this user with a Programmatic access type to enable the use of the new policy. At the end of this procedure, you will be provided with an Access key ID and Secret access key. It is important to save these values in an accessible and secured location, since they are required for running your CloudEndure solution.

1. Navigate to **Users** on the left-hand navigational menu within IAM.

2. Click on **Add user**.

3. On the Add user page, set the following:
    * **User name:** Add a username for the new user.
    * **Access type:** Check the Programmatic access option.

4. Click **Next: Permissions** at the bottom right of the page.

![](/assets/images/WIN306/CreateCEUser.png)

5. On the **Set permissions** page, select the **Attach existing policies directly** option.

6. Locate the policy you created previously. You can either search for the policy in the Search box or locate it manually by scrolling through the policy list.
    * Once you have located the policy, check the box next to it.
    * Click the **Next: Tags** button at the bottom right of the page.

![](/assets/images/WIN306/AttachPolicy.png)

7. You do not need to add any tags. Click the **Next: Review** button at the bottom right of the page.

![](/assets/images/WIN306/UserTag.png)

8. On the **Review** page, verify that the correct **User name, AWS access type** (Programmatic access), and **Managed policy** are selected. Click the **Create user** button at the bottom right of the page.

![](/assets/images/WIN306/CreateIAMUser.png)

9. A confirmation page will appear. This page provides you with your **Access key ID** and **Secret access key** which you will need to enter into the CloudEndure User Console. Click **Show** under **Secret access key** to see your key.
    * Save your **Access key ID** and **Secret access key**. Then, to finish the procedure, click the **Close** button at the bottom right

![](/assets/images/WIN306/CopyAccessKeyInfo.png)

### **Back to CloudEndure to Complete Setup**

1. In the CloudEndure console. Navigate to **Setup & Info** from the main left-hand navigational menu. Within **Setup & Info**, navigate to the **AWS CREDENTIALS** tab.
    * Enter the corresponding credentials that you obtained in the previously into the corresponding fields:
        * **AWS Access Key ID**
        * **AWS Secret Access Key**
    * After you entered your AWS credentials, click the Save button at the bottom right of the page.

![](/assets/images/WIN306/EnterUserInfo.png)




    



    * After entering your AWS credentials in the CloudEndure User Console, navigate to *Setup & Info > REPLICATION SETTINGS.*



    * Next, you will need to define your *Source* and *Target* infrastructures and regions. More information about replication settings can be found here:


https://docs.cloudendure.com/Content/Defining_Your_Replication_Settings/Defining_Replication_Settings_for_AWS/Defining_Replication_Settings_for_AWS.htm


    * Once you have set all of your settings, click the *SAVE REPLICATION SETTINGS* button at the bottom of the page.



    * You will now be able to add machines to your Project. 



    * Click SHOW ME HOW button.



    * The *How To Add Machines* pane will appear. Your Installation Token will be shown in the upper part of the pane under the *Your Agent installation token* header. For more information about installing the agents, please refer to the following link:


https://docs.cloudendure.com/Content/Installing_the_CloudEndure_Agents/Installing_the_Agents/Installing_the_Agents.htm


    * Click the *Download the Windows installer* link at the bottom of the pane under the *For Windows machines* header.



    * Copy or distribute the downloaded *Agent Installer* file to each *Source machine *that you want to include in your solution.



    * Run the *Agent Installer* file on each *Source machine* with your *Installation Token*.



    * After performing these steps, the installation will begin.



    * Once the installation is completed successfully, the replication of the *Source machine* data will start automatically, and you will be able to monitor it through the CloudEndure *User Console*.



    * A Replication Server is launched on the target location which staging disks are attached and data is replicated.



    * Once the initial sync and Data Replication are complete, the *DATA REPLICATION PROGRESS* bar will show *Continuous Data Protection *(Disaster Recovery) or *Continuous Data Replication* (Migration).



    * The *Target machine* Blueprint is a set of instructions on how to launch a *Target machine* for the selected *Source machine*. The Blueprint settings will serve as the base settings for the creation of the *Target machine*.



    * You can access the Machine’s BLUEPRINT by selecting the *BLUEPRINT* tab from the right-hand top navigation menu. For more information about configuring the target machine blueprint, please refer to the following documentation:


https://docs.cloudendure.com/#Configuring_and_Running_Migration/Configuring_the_Target_Machine_Blueprint/Configuring_the_Target_Machine_Blueprint.htm


    * Before you migrate your Source machines into the Target infrastructure, you should test your CloudEndure Migration solution. The *Test Mode* action launches and runs a Target machine in the Target infrastructure for the Source machine you selected for testing.



    * To start the test, click the purple *LAUNCH TARGET MACHINES* button and select the *Test Mode* option.



    * A confirmation message will appear. Click *CONTINUE* to perform the test.



    * Selecting the *Job Progress* menu option opens the *Job Progress* pane. The pane displays detailed information about the progress and status of several actions, including the launch of Test or Recovery machines and the deletion of Target machines.



    * During the machine conversion stage, a conversion instance will be launched temporarily to inject the required AWS binaries to the target machine root volume.



    * You can monitor the job progress until it finishes.



    * You can review the instance ID in the TARGET tab. 



    * Confirm that the Target machine was launched successfully.



    * Perform acceptance tests on the machine.






    * Once the Target machine is tested successfully, you can delete it and launch the Target machine in Cutover Mode.

