# **LAB A – Active Directory running on EC2**

## GOAL

In this lab you are going to extend an on-premise Active Directory into AWS. You will be using EC2, AWS AD Connector and AWS Systems Manager services to complete this Lab.


**LAB A – TASKS 1 thru 9 – QUICKTASK**

> Familiarize yourself with the on-premise ACME.com domain via its management server’s public-IP address (named Management Server in the console). Then we would like you to create a Server 2016 instance in VPC01 Private Subnet, use the AWS AD Connector to join it to the ACME.com domain (residing in VPC02), and then promote it to a domain controller.

**LAB A - TASK 1**

Let’s familiarize ourselves with the environment. As we mentioned, VPC02 is a simulated on-premise environment. We are going to connect via Remote Desktop (RDP) to the Management Server using its external IP address. Once connected, we will verify that the settings are correct and that the AD management tools are installed.

Go to the AWS Console you launched and complete the following steps:

- Click on **EC2**
- In the center of the screen under Resources, click on **Running Instances**
- Select the instance called **Management Server**
- You’ll find the **Public IP** address on the bottom detail screen.

Make a note of this address.

**LAB A – TASK 2**

Connect to the EC2 Instance from TASK 1-1 using Microsoft Remote Desktop

You can either do this via launching the Microsoft Remote Desktop app and adding an entry for a new host or via the command line with the following

> MSTSC /v: _IP address of EC2 Instance_

**Please call out to one of the support team in the room if you are having issues.**

Once connected, you’ll need account details to login

> Username = acme\administrator
> Password = @Pa55w0rd159@

Let’s look at Administrative Tools which you will find in the Start menu. Locate **Active Directory Users and Computers** app, launch it.

Take a look around the **ACME.COM** domain, you will see a Domain Controller called **ADSERVER1** but apart from that, it’s a brand new domain.

Please close down the remote session to this server and continue with the next task.

## TASK 2.5 – Create an IAM role

IAM Roles are configured with permissions that allow a service, assuming the role, to perform actions permitted by that role. Amazon EC2 Roles allow Amazon EC2 instances to assume a role so that applications on the instance can make secure API calls to AWS.

In this task, we will create an EC2 role which will be used by the SSM agent on our instance to perform the actions it requires with Directory Services.

1. Back at the Home screen of the AWS Management Console, click **IAM**
2. Select **Roles** from the left side menu and click on **Create role**
3. Select **AWS service** and then **EC2**
4. Select **EC2 Role for Simple Systems Manager** as your use case and click **Next:Permissions**
5. The **AmazonEC2RoleforSSM** should be selected
6. Click **Next: Review**
7. Enter **EC2RoleforSSM** as the name for the role
8. Click **Create Role**

**LAB A – TASK 3**

In this task we will create a new Windows 2016 EC2 Instance using the standard Amazon Machine Image (AMI) and then in later tasks we will configure this instance to be an AD Domain Controller.

This new EC2 Instance will be on the AWS side in **VPC01**.  In later tasks we will extend the secondary domain into this EC2 Instance.

1. In the AWS Console, click on **EC2**
2. Next click on Launch Instance

![create-instance](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/create-instance.png)

3. Scroll down the list of Amazon Machine Images until you find **Microsoft Windows Server 2016 Base** and then click **Select**

![win-2016](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/win-2016.png)

4. On the Choose an Instance Type screen select T2.Large and click **Next: Configure Instance Details**

![instance-type](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/instance-type.png)

5. You will need to make sure you select the following on the Configure Instance Details screen

>   NETWORK = VPC01-VPC

>   SUBNET = VPC01-SNEXTPUB1A

>   AUTO-ASSIGN PUBLIC IP = Enable

>   IAM Role = AmazonEC2RoleforSSM

You can leave all other parameters at their default.

6. Click **Next: Add Storage**
7. Click **Next: Add Tags**
8. Click **Next: Add Security Groups**
9. Click **Add Rule**
10. Make sure that an RDP rule for port 3389 with a Source of **My IP** is present
![sg-rule](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/sg-rule.png)**NOTE: We advise that you restrict access of RDP Traffic to your own network**
12. Click **Review and Launch**
13. On the Review Instance Launch screen click **Launch**
14. On the **Select an existing key pair** screen ensure that you select **Create a new key pair** , give it a Key Pair Name and ensure that you Download the file to your laptop.
14. Then click **Launch Instances**


**LAB A – TASK 4**
In this task we are going to use the AWS AD Connector Service to allow us to connect our newly created EC2 Instance to the **ACME.COM** domain that resides in **VPC02**.

1. In the AWS Console, click on **Directory Service**
2. On the Directories screen click on **Set up directory**
3. On the Select directory type screen select AD Connector and click **Next**
4. On the Enter AD Connector information screen select Directory size of **Small** and click Next
5. On the *Choose VPC and subnets* screen enter the following:

>   VPC – VPC01-VPC

>   Subnets – VPC01-SNEXTPUB1A

>   VPC01-SNEXTPUB1B

![AD Connector](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/A-4-5_cut.png)

7. Click **Next**
8. On the *Active Directory Information* screen enter the following details:

>   Directory DNS name – acme.com

>   Directory NetBIOS name – acme

>   DNS IP Address – 10.1.16.5

>   Service account username – administrator

>   Service account password – @Pa55w0rd159@

![AD Connector2](https://s3.us-east-2.amazonaws.com/win309images/A-4-8.png)

 - Click **Next**
 - Finally, on the Review and Create screen, check all settings and then click **Create directory**
*NOTE: It is best practice to reduce the permissions assigned to the Service Account used during the AWS AD Connector setup. The following link has best practice guidelines: https://docs.aws.amazon.com/directoryservice/latest/admin-guide/prereq_connector.html?icmpid=docs_ds_console_help_panel#connect_delegate_privileges*

## TASK 4.5 – Create a new DHCP Options set

DHCP Option Sets cannot be modified. If you require your VPC to use a different set of DHCP options, you must create a new set and associate with your VPC. In this section, you will create a new DHCP Option Set which will be used by EC2 instances launched into VPC01.

1. In the AWS Management Console on the services menu, go back to the home screen and then click on VPC
2. Choose DHCP Option Sets from the side menu
3. Choose Create DHCP options set
![dhcp](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/dhcp.png)
4. Enter these values in to the relevant fields:

>   Name Tag = **dopt-acme**

>   Domain name = acme.com

>   Domain name servers = 10.1.16.5

>   NTP servers = (leave blank)

>   NetBIOS servers = (leave blank)

>   NetBIOS node type = (leave blank)


5. Choose Yes, Create

## TASK 4.6 – Associate the new DHCP Options set with your VPC

The next step is to associate our newly created DHCP Option Set with our VPC.  After you associate a new set of DHCP options with a VPC, any existing instances and all new instances that you launch in the VPC use these options. You don't need to restart or relaunch the instances.

1. Go back to the VPC services menu
2. Select **Your VPCs** from the left menu and then select the VPC labelled **VPC01-VPC**
3. Click on Actions and Select **Edit DHCP Options Set**
4. From the list, select the DHCP Option Set with the name given in Task 4.5 **dopt-acme**
5. Click Save
![DHCP Option Set](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-2-5.png)


**LAB A – TASK 5**
You can download the [Port Verification Tool](http://docs.aws.amazon.com/directoryservice/latest/admin-guide/samples/DirectoryServicePortTest.zip) to troubleshoot AD Connector or Microsoft AD Trust setup issues from here: Directory Service Port Test
The AD Connector Port Verification Tool does two things:

 - Determines if the necessary ports are open from the VPC to your domain
 - Verifies the minimum forest and domain functional levels.

 Usage:
```
     DirectoryServicePortTest.exe -d <domain_name> -ip <server_IP_address> -tcp "53,88,135,389,445,464,3268,3269,5722,9389" -udp "53,88,123,138,389,445"
```

 1.	Start a Remote Desktop session with your newly created EC2 Instance.
 2.	Start Internet Explorer and browse to the following link.
 https://docs.aws.amazon.com/directoryservice/latest/admin-guide/samples/DirectoryServicePortTest.zip

 3.	If **Internet Explorer Enhanced Security Configuration** is enabled <graphic18.5) then follow the instructions below to disable it.
         a.	Click on start and click on **Server Manager**
         b.	On the left hand side of Server Manager click on Local Server
         c.	On the large Properties pane find IE Enhanced Security Configuration and confirm it’s set to ON
         d.	Click on the ON link
         e.	<Graphic18.6> Click OFF for Administrators option. Click ok.
         f.	Restart Internet Explorer.
 4.	Download the tool, and extract the .zip file to the **C:\TEMP** folder.
 5.	Start a Command Prompt prompt via the Start Menu.
 6.	Change to the **C:\TEMP** folder via CD C:\TEMP  
 7.	Enter the following –

```
  directoryserviceporttest -d acme.com – ip “10.1.16.5”
```


 8.	You should see the following confirmation

 ![Port Test](https://s3.us-east-2.amazonaws.com/win309images/A-5-8.png)

**LAB A – TASK 6**

In this task we will perform the simple task of joining our newly created EC2 Instance to the ACME.COM domain.  

There are numerous ways of doing this such as
-	Adding a Powershell script to the USERDATA section when launching the EC2 Instance
-	Using the AWS Systems Manager ‘Run Command’ service to run a Powershell script
-	Use the new AWS Systems Manager ‘Session Manager’ to create a session with the instance

Since you may not have had the chance to use Session Manager yet, lets choose this option.

1.	In the AWS Console search for Systems Manager under Management Tools and select.
2.	AWS Systems Manager gives you a lot of functionality that will help you manage your long-running AWS EC2 Instances.  On the left hand side menu choose Session Manager
3.	This screen gives you details of previous used sessions and also you can configure session-logging in the Preferences tab.  Click Start Session

![start Session](https://s3.us-east-2.amazonaws.com/win309images/A-6-3.png)

4.	There should be three EC2 instances viable in the Target Instances screen. Select the Instance ID that corresponds to your newly created instance and select using the radio-button on the left and then click the Start Session button.
5.	A Powershell Prompt will appear in your browser.
6.	Type or paste the following –
## **please enter each line individually**


```
  Set-DNSClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses (“10.1.16.5”)

  $domain = "acme.com"

  $password = "@Pa55w0rd159@” | ConvertTo-SecureString -asPlainText -Force

  $username = "$domain\administrator"

  $credential = New-Object System.Management.Automation.PSCredential($username,$password)

  Add-Computer -DomainName $domain -Credential $credential -restart

```


7.	You should get the following response

![Join Domain](https://s3.us-east-2.amazonaws.com/win309images/A-6-7.png)

8.	The EC2 Instance restarts and joins the domain ACME.COM.
9.	After the restart see if you can connect it using the ACME.COM credentials.


**LAB A – TASK 7**

In this task we will promote our newly created instance to become a Domain Controller in the **ACME.COM** domain.
We will use AWS Systems Manager’s Session Manager service once again.

1.	Back to the AWS Console, find and select AWS Systems Manager
2.	In the AWS Systems Manager screen, select Session Manager on the left.
3.	Click Start Session
4.	Select the EC2 we created in TASK 3 and click Start Session
5.	Type or cut and paste the following Powershell into the Session. Please enter the commands Line by Line

```
  Add-WindowsFeature AD-Domain-Services, RSAT-AD-AdminCenter,RSAT-ADDS-Tools

  $domain = "acme.com"

  $password = "@Pa55w0rd159@” | ConvertTo-SecureString -asPlainText -Force

  $username = "$domain\administrator"

  $credential = New-Object System.Management.Automation.PSCredential($username,$password)

  install-addsdomaincontroller -installdns -Credential $credential -domainname acme.com
```

You’ll be asked to provide a SafeMode Administrator Password. Type the following  ReInvent2018
You’ll receive the following message – enter Y (for Yes)
![DCPromo](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/A-7-5.png)

**Congratulations !**
**_We’ve used AWS AD Connector to extend on on-premise Active Directory into AWS and then created a domain controller in the ACME.COM domain_**





# LAB B – Using the AWS Directory Service for Active Directory

## GOAL

In this lab you are going to configure the instance of AWS Directory Services that has already been created for you. You will then create EC2 Instances which are automatically domain joined when they start.

## STRETCH GOAL

You will configure federated Single Sign on to the AWS Console for Active Directory users.  We will also Share our AWS Directory Services domain into a separate VPC.

## QUICKTASK
In this next lab you will complete the configuration of **_AWS Directory Services for Active Directory_**
This includes setting DHCP Option Sets in VPC01 and configuring a AWS Systems Manager role that will enable an EC2 Instance to Auto-Join the **corp.example.com** domain when it launches. After that is complete we will configure a Domain Trust with ACME.COM

## Gathering information

Before we begin, we need to gather some information that will be required throughout the tasks ahead.

In the AWS Console, select **Directory Service** from the Security, Identity & Compliance section of services. Or just type **_Directory_** in the Console search bar and select the Directory Service.

You will see a single Directory already created for you.  Click on the **Directory ID** link.

On the next screen, you'll find details of the Directory.  Make a note of the following items...

- Directory ID
- DNS Address (x2)

The DNS addresses (x2) are the individual IP addresses of each domain controller pre-created in separate Availability Zones inside a single VPC.

## TASK 1 - Configuring a VPC to use your DNS servers

The Dynamic Host Configuration Protocol (DHCP) provides a standard for passing configuration information to hosts on a TCP/IP network. The options field of a DHCP message contains the configuration parameters. Some of those parameters are the domain name, domain name server, and the NetBIOS-node-type.

DHCP Option Sets are associated with your virtual private cloud (VPC).

The default DHCP Option Set resolves DNS requests via Route 53. With Windows we need our instances to resolve their DNS via our Domain Controllers. In this lab we will create a new DHCP Option Set and redirect DNS requests to our AWS Directory Service.

## TASK 2 – Create a new DHCP Options set

DHCP Option Sets cannot be modified. If you require your VPC to use a different set of DHCP options, you must create a new set and associate with your VPC. In this section, you will create a new DHCP Option Set which will be used by EC2 instances launched into VPC01.

1. In the AWS Management Console on the services menu, go back to the home screen and then click on VPC
2. Choose DHCP Option Sets from the side menu
3. Choose Create DHCP options set
![dhcp](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/dhcp.png)
4. Enter these values in to the relevant fields:

>   Name Tag = **dopt-corp**

>   Domain name = corp.example.com

>   Domain name servers = (The two IP addresses for your AWS Directory Services DNS Servers that you noted earlier. Use a comma to separate them)

>   NTP servers = (leave blank)

>   NetBIOS servers = (leave blank)

>   NetBIOS node type = (leave blank)

![DHCP Option Set](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-2-4.png)

5. Choose Yes, Create

## TASK 3 – Associate the new DHCP Options set with your VPC

The next step is to associate our newly created DHCP Option Set with our VPC.  After you associate a new set of DHCP options with a VPC, any existing instances and all new instances that you launch in the VPC use these options. You don't need to restart or relaunch the instances.

1. Go back to the VPC services menu
2. Select **Your VPCs** from the left menu and then select the VPC labelled **VPC01-VPC**
3. Click on Actions and Select **Edit DHCP Options Set**
4. From the list, select the DHCP Option Set with the name given in Task 1 **dopt-corp**
5. Click Save
![DHCP Option Set](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-2-5.png)

## TASK 4 - Domain Join Part 1

**Overview**
For our second task, we are going to configure AD domain auto-join. This requires the creation of an SSM Document and IAM role. The process is simplified as AWS will automatically create the SSM document for you when you first launch an instance.

The steps below take you through the creation of the IAM role, and then finally we launch an Amazon EC2 instance that will automatically join the **corp.example.com** domain running on AWS Directory Services.

## TASK 5 – Create an IAM role

### If you worked through LAB A first then you will have already created an IAM role called EC2RoleforSSM.  You can then skip this task.  If not, please follow the instructions below.

IAM Roles are configured with permissions that allow a service, assuming the role, to perform actions permitted by that role. Amazon EC2 Roles allow Amazon EC2 instances to assume a role so that applications on the instance can make secure API calls to AWS.

In this task, we will create an EC2 role which will be used by the SSM agent on our instance to perform the actions it requires with Directory Services.

1. Back at the Home screen of the AWS Management Console, click **IAM**
2. Select **Roles** from the left side menu and click on **Create role**
3. Select **AWS service** and then **EC2**
![SSM Role](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-1-3.png)
4. Select **EC2 Role for Simple Systems Manager** as your use case and click **Next:Permissions**
5. The **AmazonEC2RoleforSSM** should be selected
6. Click **Next: Review**
7. Enter **EC2RoleforSSM** as the name for the role
8. Click **Create Role**

## TASK 6 – Launch an Instance

In this task, we will launch a new instance into VPC01 and attach the IAM role that we created in the previous task.

1. On the Services menu, click **EC2**
2. Select **Launch Instance**
3. Select **Microsoft Windows Server 2016 Base** as the AMI
4. Choose **t2. medium** as the instance type
5. Click **Next:Configure Instance Details**
6. In the Configure Instance Details Screen, ensure the following settings:

>   Network VPC, select VPC01

>   Subnet, select VPC01-SNEXTPUB1A

>   Auto-Assign Public-IP should be set to ENABLE

>   Domain join directory should be set to **corp.example.com**

> I AM role should be set to EC2RoleforSSM  (which we previously created in TASK 5)

![SSM Role](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-6-6.png)

7. Click **Advanced Details** at the bottom of the screen which will show the Userdata section
8. Copy and Paste the following PowerShell code into the Userdata section which will install the required management tools
```
<powershell>
Import-Module Servermanager
Install-WindowsFeature RSAT, RSAT-DNS-Server
</powershell>
```
![User Data](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-6-8.png)

8. Select **Review and Launch**
9. You'll receive a security warning that we are not using Free Usage Tier. Click **Launch**.
10. Select the existing Key Pair from LAB A. Acknowledge via the check-box and click Launch Instances

**_NOTE: Make a note of the Instance-ID of the new EC2 instance you've just launched_**

Whilst our Amazon EC2 instance is launching, let's complete another task before returning to the instance.

## TASK 7 – AWS Directory Service Event Notification

As a Windows server administrator, understanding when you have an issue with a domain controller is vital. Windows Server has a built-in logging system via Event Viewer, but to be notified when the AWS Directory Service itself has a problem we create a notification using SNS.

Configure SNS
1. Go to the Home screen of the AWS console

2. Select **Directory Service**

3. On the Directories page, choose the directory ID for the **corp.example.com** domain

4. Choose **Monitoring** and then **Create Notification**

5. Choose **Create a new notification**

6. Choose **Recipient Type** as Email and enter an email address that is accessible to you during the workshop

7. Choose **Advanced Options** and ensure your SNS topic starts with DirectoryMonitoring

8. Choose Add

![SNS](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-7-8.png)

## TASK 8 – Confirm Subscription

You will receive an email asking you to confirm your subscription to the SNS notification.  Click the link to confirm the subscription.

## TASK 9 – Domain Join Part 2

**Verify your instance is joined to the domain**

Switching back to the Amazon EC2 instance we previously launched in Task 2. Let's find the Instance-ID in Amazon EC2 Services and note the Public IP of the instance.

1. Using the Remote Desktop client for your machine, connect to the EC2 instance Public IP address
*NOTE: You will receive a Certificate error when connecting to the instance, select continue*
2. Login to the server using the **corp.example.com** domain account using the details below:

> Username: **corp.example.com\admin**

> Password: **@Pa55w0rd159@  (case-sensitive)**

3. This will demonstrate that your EC2 instance is joined to the **corp.example.com**  domain
*NOTE: If you fail to connect, check the status of the EC2 instance in the console to ensure it has finished launching.*

## TASK 10 – Configuring DNS resolution

In the first task, we created a new DHCP options set and associated it with VPC01. This option set will allow instances launched into VPC01 to resolve DNS hostnames for **corp.example.com**  .

In this task, we will configure DNS to allow our AWS resources to resolve DNS hostnames for acme.com  domain as well as vice versa.


We need to make changes to the existing security group attached to the Directory Services domain controllers, this will allow the outbound connectivity required between the Directory Services located in VPC01 and resources in VPC02.

1. On the Services menu, click **EC2**
2. On the sidebar, select **Security Groups**
3. You should see a number of security groups already created.  One will have the Group Name that will have a suffix of controllers. This is the security group automatically created when we launched AWS Directory Services
4. Select this Security Group and select the **Outbound** tab
5. Click Edit and add a new Security group rule as per the following:

> Type = ALL Traffic

> Protocol = ALL

> Destination = 10.1.0.0/16

6. Click **Save**

## TASK 11 - Continuing DNS Configuration

1. If you have closed your existing remote desktop connection, using the Remote Desktop client for your machine, connect to the EC2 instance public IP address you previously created in task 2.2
2. Login to the server using the **corp.example.com** domain account using the details below:

> Username: **corp.example.com\admin**

> Password: **@Pa55w0rd159@  (case-sensitive)**

3. Once successfully logged in, go to Windows Administrative Tools on the Start Menu and select DNS to launch the Windows DNS Manager
*NOTE: Ensure that the DNS server you connect to is one of the AWS Directory Services instances which you noted at the start of the lab.*
![DNS Config](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-11-3.png)
4. In the left-hand side navigation window make sure that you have selected the DNS Server
5. We are going to add an entry for a Conditional Forwarder that will point to the VPC02 Domain Controller and DNS server
6. Right-click Conditional Forwarders, and select New Conditional Forwarder
7. Enter a domain of acme.com and the IP address of the master server 10.1.16.5
*NOTE: Ignore any errors in the DNS console reporting "cannot resolve FQDN"*

![DNS confirmation](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-11-7.png)

## TASK 12 Setting a DNS Conditional Forwarder

We now add a Conditional Forwarder on the acme.com Domain Controller located in VPC02.

1. Using the Remote Desktop client for your machine, connect to the VPC02 Management Server using the IP address shown in the Qwiklabs Connection Settings on the Left Hand Side of the screen
2. Login to the server using the acme.com domain account using the details below:

> Username: **acme.com\Administrator**

> Password: **@Pa55w0rd159@  (case-sensitive)**

3. Once successfully logged in, go to Windows Administrative Tools on the Start Menu and select DNS to launch the Windows DNS Manager
*NOTE: Ensure that the DNS server you are connected to is ADSERVER1*
![SSM Role](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-12-3.png)

4. In the left-hand side navigation window make sure that you have selected DNS
5. We are going to add an entry for a Conditional Forwarder that will point to the AWS Directory Services instances in VPC01
6. Right-click Conditional Forwarders, and select New Conditional Forwarder
7. Enter a domain of **corp.example.com**  and the IP address of both AWS Directory Services instances you noted at the start of the lab. Ignore the 'Unable to resolve' message and click OK

## TASK 13 – Configuring a Domain Trust

One of the most common configurations for AWS Directory Services is adding AWS resources to AWS Directory Services and configuring a trust between AWS Directory Services and an existing Active Directory domain.

This configuration isolates AWS resources into a separate, AWS hosted domain, while allowing Single Sign On from your on premise domain.

In this task, we will create a Domain Trust to support this configuration.

*NOTE: Trusts can either be one of three things. Incoming, Outgoing and Bi-directional.  It is important to understand that permissions are granted in the opposite direction to where the trust is.*

![AD Trusts](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/DIAGRAM.png)
*corp.example.com* creates an outgoing trust to *acme.com* This allows *acme.com* access to *corp.example.com* resources

Think of it as, *corp.example.com* trusts *acme.com* to access its resources.

## TASK 14 – Creating a Trust - VPC02 side

1. Using the Remote Desktop client for your machine, connect to the VPC02 Management Server using an IP address that you can find via the EC2 Console by selecting the EC2 Instance called **VPC02 Management Server**
2. Open Active Directory Domains and Trusts which you will find in the Start Menu under Windows Administrative Tools
3. In the left-hand navigation pane right-click our domain acme.com and select Properties
4. In the *acme.com* Properties screen, select the middle tab Trusts
5. At the bottom of the screen click New Trust and the New Trust Wizard appears
6. Click Next on the Welcome Screen
7. Next, we are going to give our trust a name, name it **corp.example.com** and click Next
8. In the Trust Type screen select Forest trust and click Next
9. In the Direction of Trust screen select One-Way Incoming and click Next
10. In the Sides of Trust screen select This domain only and click Next
11. In the Trust Password screen provide a password of *@Pa55w0rd159@* and click Next
12. Click Next, Next
13. Select No, do not confirm the incoming trust
14. Click Next, Finish

## TASK 15 - Creating a Trust - AWS side

1. Go to the AWS Management Console and select Directory Service
2. With the Directories tab selected click on the directoryID for the **corp.example.com** domain
3. Select the Trust Relationship tab in the middle of the page

![SSM Role](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-15-3.png)

4. Click on the Add trust relationship button
5. The Add a trust relationship detail page appears. Enter the following

> Remote domain name = acme.com

> Trust password = @Pa55w0rd159@

> Trust direction = One-Way: Outgoing

> Conditional forwarder = 10.1.16.5  (The IP address of acme.com Domain Controller)

6. Click Add
7. Back at the Directory page you'll see a message stating that the One-Way: Outgoing trust is being created
8. The Status of the trust relationship should be Verified in a few minutes

![Trust Verified](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-15-8.png)


## TASK 16 - STRETCH GOAL - Share the CORP.EXAMPLE.COM domain to another Account

In this task we will show one of the very recent additions to AWS Directory Services functionality.  It is now possible to share an AWS Directory Service domain across VPC and also across different accounts.

1. Go to the AWS Console, find and select **Directory Services**
2. You will see a number of directories already created including one for **corp.example.co**
3. Click on the Directory ID hyperlink of the Corp.Example.com domain. **d-########**
![Directory ID](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-16-3.png)
4. Scroll down the page where you can see a new tab called **Scale & Share** click that tab
![Scale & Share](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-16-4.png)
5. Click on **Create new shared directory**
6. You have two options which are **Share this directory with AWS Accounts inside your organization** and Option B which is **Share this directory with other AWS Accounts**
You need to be running AWS Organizations in order to do the first, but we can test out the second option by asking the student next to you for their account ID and adding it during this task.
7. You then have the option of adding a note as part of the Directory sharing process. Add a note if you like and then click SHARE at the bottom of the page.

**Work with your partner to check that Directory Sharing works**

8. In your partners account, make sure you are using the correct region and then go to the **Directory Services** screen.  In the **Directories Shared with me** link on the left hand side you see a notification.
![Shared with me](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-16-8.png)
9. Select the Directory and click **Review**
10. The Pending Shared Directory Invitation screen appears.  Select the agreement and click **Accept**
![Pending Invite](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/B-16-10.png)
You can test this out by launching an EC2 Instance and adding it to the **Corp.Example.com** domain

Congratulations you have completed this lab.

## LAB C – Federating Single Sign On for AWS Console

**Overview**

In this final exercise, we implement federation to the AWS Console from the Active Directory domain (acme.com).  We will create users, groups and configure mapping between these and IAM roles.

**Objectives**

We are going to configure the AWS Console single-sign-on (SSO) to acme.com Active Directory domain.

**Task 1 – Creating Users & Groups**

1. Firstly, we need to create some users and groups in the **corp.example.com** domain.  Remote Desktop into the VPC01 Management Server, Go to the Start Menu and launch PowerShell.
2. Copy and paste the following PowerShell commands.

Create AD Groups

```
New-ADGroup -Name AWSDevelopers -GroupScope DomainLocal

New-ADGroup -Name AWSAdmins -GroupScope DomainLocal
```

Create Users

```
New-Aduser -Name "Williams" -GivenName William -Surname Gates -SamAccountName William -UserPrincipalName william@acme.com -accountPassword

(ConvertTo-SecureString -AsPlainText "@Passw0rd158@@" -Force) -PassThru -enable $True

New-Aduser -Name "Alex" -GivenName Alex -Surname Summer -SamAccountName Alex -UserPrincipalName alex@acme.com -accountPassword (ConvertTo-SecureString

-AsPlainText "@Passw0rd158@@" -Force) -PassThru -enable $True
```

Add Users to Groups

```
Add-ADGroupMember AWSDevelopers William

Add-ADGroupMember AWSAdmins Alex
```

**Task 2 – Creating an EC2 Developer IAM role**

1. In the AWS console, select the **IAM**  service
2. In the IAM service screen select **Roles** in the Navigation pane
3. Select **Create role**
4. In the Create Role screen select **AWS Service**, choose **Directory Service** and click **Next: Permissions**
5. In the Attach permissions policies screen find the following policy **AmazonEC2ReadOnlyAccess** make sure you tick the box to select it and then choose **Next:Review**
6. In the review screen enter a role name of **EC2Developer** and click **Create role**

**Task 3 – Creating an EC2 Administrator IAM role**

1. In the AWS console, select the **IAM** service
2. In the IAM service screen select **Roles** in the Navigation pane
3. Select **Create role**
4. In the Create Role screen select **AWS Service**, choose **Directory Service** and click **Next:Permissions**
5. In the Attach permissions policies screen find the following policy **AmazonEC2FullAccess** make sure you tick the box to select it and then choose **Next:Review**
6. In the review screen enter a Role Name of **EC2Admin** and click **Create role**

**Task 4 – Creating an Access URL**

1. In the AWS Console , select the **Directory Service**
2. Select the directory ID for domain **corp.example.com**
3. Choose the **Apps & services** tab where you'll see the Access URL box
4. Select a unique name to add to the URL and click Create Access URL. This process may take a few minutes
5. To Confirm - the directory Access URL would be https://uniquename.awsapps.com

**Task 5 – Enabling AWS Management Console access**

1. In the AWS Console, select the **Directory Service**
2. Further down the page you'll see a list of AWS Apps & services
3. Select **AWS Management Console** and choose **Enable Access**
4. You will see the console URL next to the newly Enabled AWS Management Console link

**Task 6 – Assigning AD Users and Groups to IAM roles - Developers**

1. From the Directory Service screen click **AWS management Console** on the Apps & services tab
2. You’ll be presented with a confirmation pop-up, click Continue to be redirected to the manage access screen
3. On the Add Users and Groups to Roles screen you will see the two roles we created in Task 1.1 in this section
4. Click on the EC2Developer role which will take you to the Role Detail: EC2Developer screen
5. Click **Add** under Assigned Users and Groups
6. Make sure that the **corp.example.com**  domain is selected and then choose the Group radio button
7. In the search box type **AWSDevelopers**  and then **Add**

**Task 7 – Assigning AD Users and Groups to IAM roles – Administrators**

1. Following on from the last task. From the Directory Service  screen, once again select **AWS Management Console**
2. Choose the **EC2Admin** role which takes you to the Role Detail: EC2Admin screen
3. Click **Add**
4. Click Group and search for AWSAdmins in the search box and then click Add
*NOTE: You can change the length of time allowed on the console by changing the Login Session Length number at the Add Users and Groups screen*

**Task 8 – Testing access - AWS Developers**

1. In a new browser window, browse to the Access URL you configured in Task 1.2

> Username = **corp.example.com\william**

> Password = **@Passw0rd158@@**

2. Go into EC2 and click Instances.  Now click Launch Instances and attempt to create an EC2 instance – you should receive an error message because Alex only has ReadOnly access
3. Don't forget to Sign-out of the AWS Console and close the browser window

**Task 9 – Testing access - AWS Admins**

1. In a new browser window, browse to the Access URL you configured in Task 1.2

> Username = **corp.example.com\alex**

> Password = **@Passw0rd158@@**

2. Go into EC2 and click Instances.  Now click Launch Instances and attempt to create an EC2 instance - you should be able to successfully launch an instance because William has Full Access
3. Sign out of the console, and close down the browser window





##LAB D - BONUS LAB – AWS Systems Manager

**Overview**

AWS Systems Manager provides a number of critical services that will help you manage and maintain long running EC2 instances in AWS.    If you have EC2 Instances that are immutable then you’ll need a way of managing those instances and AWS Systems Manager is the best way of doing that.
During this Bonus Lab we will give you a quick run through of some critical AWS Systems Manager services that you might use.

**Objectives**

After completing this lab, you will be able to:

- Remotely execute a command using Run Command
- Configure and use the Inventory service to collect configuration and instance information
- Create a Parameter store value
- Use State Manager to create a task and apply to your instances
- Define a Maintenance Window for disruptive tasks
- Configure and Schedule Patch Management

**LAB D – TASK 1 -  Running a command remotely**

In this task, you will use Run Command to remotely and securely execute a PowerShell command on your Windows instance to verify the instance name and domain membership.

Execute the command

1. On the   Services   menu, click   EC2  
2. Scroll down to   SYSTEMS MANAGER SERVICES  , click   Run Command  

![Run Command](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman12.png)

3. Click   Run a command  
4. On the   Command document   page, click   **AWS-RunPowerShellScript**  you’ll find it on the third page along.
5. For **Select Targets by**, choose one of the EC2 instances that you previously created
6. In the **commands** detail, type the following text:

```
 (Get-WmiObject Win32_ComputerSystem).Name

(Get-WmiObject Win32_ComputerSystem).Domain
```

7. Leave the fields   Working Directory   and   Execution Timeout   as defaults
8. For   Comment  , add a comment to help you identify this command
9. Click   Run   to execute the command

LAB D – TASK 2 - View the results
1.  Once the command is complete, choose   View result  
2.  You will be returned to the Run Command windows where the job details will be displayed, Click   Output   from the bottom pane

![Output](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman22.png)

3. Click   View Output   to display the output from the PowerShell command
4. You will now see the results of the PowerShell command that was executed on your instance, it should display the instance name and domain information
5. Click   Close   to return to the previous screen

LAB D – TASK 3 - Bonus Task
1. [1]Try running some other familiar PowerShell commands on the instance(s) and viewing the output, for example can you verify the trust relationship between the domains?

**LAB D – TASK 4 - Inventory**

In this task, you will setup the Inventory service to collect configuration and inventory information of all instances in VPC02 to identify which version of the SSM Agent is installed on your instances.

Configure Inventory
1.  Click **Managed Instances** from the **SYSTEMS MANAGER SHARED RESOURCES** menu

![Inventory](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman31.png)

2.  Click **Setup Inventory**
3.  In **Targets**, Click Select Targets by **Specifying a Tag** and in the selection box choose **Tag Name – Environment**,   Tag Value – VPC02  
4.  We will leave the Schedule to execute   Every 30 Minutes  
5.  We will ensure all the **Parameters** are **Enabled**

![Inventory Scheduling](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman35.png)

6.  Click **Setup Inventory**

![Setup Inventory](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman36.png)

7.  Click **Close**

**LAB D – TASK 5 - Execute Inventory**
1.  As the task may not execute for 30 minutes, Click **State Manager** from the **SYSTEMS MANAGER SERVICES** menu

![ExecuteInventory](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman38.png)

2.  Click on the **AWS-GatherSoftwareInventory** Document Name
3.  Click on **Instances** to view the targeted instances, you should see your instance

![Targeted Instances](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman39.png)

4.  Click **Apply Association Now** to force the inventory task to execute immediately

![Setup Inventory](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman40.png)

**LAB D – TASK 6 - View Inventory Results**
1.  Return to   Managed Instances   from the **SYSTEMS MANAGER SHARED RESOURCES** menu
2.  Click on **your instance** and Click **Inventory**
3.  From   Inventory Type  , Select   AWS:Application  

![View Inventory](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman41.png)

4.  This will now display the installed AWS Applications including the SSM Agent version

**LAB D – TASK 7 - Bonus Task**
Using the inventory data, can you identify the following?

1. [1]What roles are installed on the server?
2. [2]Is IIS installed and running?

___
**LAB D – TASK 8 - Parameter Store**

The Parameter store provides a centralized location to store, provide access control, and easily reference your configuration data, whether plain-text data such as database strings or secrets such as passwords, encrypted through AWS Key Management Service (KMS).  In this task, we will create an administrator password parameter which we will later use to apply to Windows instances.

Create Parameter in the Store
1.  Click   Parameter Store   from the   SYSTEMS MANAGER SHARED RESOURCES   menu

![Parameter Store](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman42.png)

2.  Click Get Started Now  
3.  For Name type WindowsAdministratorPassword  
4.  For Description type Windows local administrator password  
5.  For Type select String  
6.  For Value type

**L0calAdm1nPa55word@**

7.  Click   Create Parameter  

![Setting a Parameter](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman43.png)

8.  Click   Close  

___
**LAB D – TASK 9 - State Manager**

Systems Manager State Manager is a secure and scalable configuration management service that ensures your Amazon EC2 and hybrid infrastructure is in a desired or consistent state, which you define. In this task, we will create an association to apply to the Windows servers with a job that will regularly update the local administrator password to the value previously created in the parameter store.

Create Association
1.  Click State Manager from the SYSTEMS MANAGER SERVICES menu
2.  Click Create Association  
3.  For Association Name, Type SetWindowsLocalAdminPassword  
4.  For Document select AWS-RunPowerShellScript  
5.  Click Select Targets by Specifying a Tag and in the selection box choose Tag Name – Platform, Tag Value – Windows  
6.  We will leave the Schedule to execute Every 30 Minutes  
7.  In the commands detail, use the following values:

```

Net.exe user administrator {{ssm:WindowsAdministratorPassword}}

```

8.  Leave the default values for the Working Directory and Execution Timeout and Click   Create Association  

![State Manager](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman45.png)

9.  After the Association has been successfully created, Click   Close  

**LAB D – TASK 10 - Execute Association**
1.  As the task may not execute for 30 minutes, Click   State Manager   from the   SYSTEMS MANAGER SERVICES   menu
2.  Click on the **SetWindowsLocalAdminPassword** Association
3.  Click   Instances   to view the targeted instances and the status
4.  To force the association, Click   Apply Association Now  

![State Manager](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman40.png)

**LAB D – TASK 11 - Test Association**
1.  To test that the local administrator password has been successfully changed on your Windows instances, ensure you are logged out of any remote desktop sessions.
2.  Connect using remote desktop to your existing Windows instance using the local computer administrator account with the new password:
- User:   .\administrator  
- Password:   L0calAdm1nPa55word@  

___
**LAB D – TASK 12 -  Maintenance Windows**

In this task, we will define a maintenance window for patches to be applied at 4 PM on every Tuesday for 4 hours.

Create a Maintenance Window
1.  Click Maintenance Windows from the SYSTEMS MANAGER SHARED RESOURCES menu
2.  Click Create a Maintenance Window  
3.  For Name Type MyNightlyMaintenanceWindow  
4.  Click CRON/Rate expression  
5.  For CRON/Rate expression  , Type


**cron(0 16 ?   TUE  )**


6.  For Duration, Type   4  
7.  For Stop initiating tasks, Type   1  
8.  This will create a maintenance Window that runs at 4 PM on every Tuesday for 4 hours, with a 1 hour cutoff
9.  Click Create maintenance window  

![Maintainance Windows ](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman46.png)

**LAB D – TASK 13 - Register targets with a Maintenance Window**
1.  Click **Maintenance Windows** from the   SYSTEMS MANAGER SHARED RESOURCES   menu
2.  Click **MyNightlyMaintenanceWindow** from the maintenance windows
3.  Click **Actions**, **Register targets** from the drop-down menu
4.  For **Target Name** Type **MyWindowsInstances**
5.  Click Select Targets by **Specifying a Tag** and in the selection box choose **Tag Name – Platform**,   Tag Value – Windows  

![Register Targets](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman47.png)

6.  Click **Register targets**
7.  Once target registration has been successful, Click   Close  

**LAB D – TASK 14 - Patch Manager**

In this task, we will configure Patch Manager to help you select and deploy operating system and software patches automatically to your instances by using the default patch baseline.

Register the patch manager task with the maintenance windows
1.  Click **Maintenance Windows** from the **SYSTEMS MANAGER SHARED RESOURCES** menu
2.  Click **MyNightlyMaintenanceWindow** from the maintenance windows
3.  Click **Actions**,   Register run command task from the drop-down menu
4.  For **Name**, Type **WindowsPatching**
5.  In the **Document** section, choose **AWS-RunPatchBaseline**
6.  In **Strict targets** ensure your Maintenance Window target is selected, this may be identified by a unique ID rather than by name

**LAB D – TASK 15 - Create the required IAM role**
1.  For **Role**, click **Add new custom role**
2.  Click **Create role**
3.  Select **EC2**, and click **Next: Permissions**
4.  In **Policy type**, Type

**AmazonSSMMaintenanceWindowRole**


5.  Select the **AmazonSSMMaintenanceWindowRole** policy and click   Next: Review  
6.  For **Role name** type **ec2_AmazonSSMMaintenanceWindowRole*

![Maintainance Windows ](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman48.png)

7.  Click **Create role**

**LAB D – TASK 16 - Complete the configuration**
1.  Return to your AWS Console windows and click the Refresh icon next to the Role  
2.  You should now be able to select the newly created role within the Role drop-down

![Maintainance Windows ](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman49.png)

3.  For Execute on enter   5  
4.  For Stop after enter   5  
5.  For Operation, change to Install  
6.  Leave all other fields as default and click Register task  
7.  Once the task has been successfully registered, click Close  
8.  Select your Maintenance Window task and check the associated tasks and targets to check its setup correctly

  Congratulations you have now successfully configured a Maintenance Window to execute at 4 PM on every Tuesday for 4 hours that will patch all your Windows instances 5 at a time  

**LAB D – TASK 17 - Run Patch Baseline**
  Bonus Task  

As we won't be around next Tuesday at 4PM, execute a patch baseline against our Windows instances to view the patch status immediately

1.  Execute a Run command on your instances using AWS-RunPatchBaseline, Note: it can take >10 minutes to execute on the instances
2.  Once complete select your instances in Patch Compliance and view the compliance status
3.  From Managed Instances click Filter by attributes and select AWS:ComplianceItem.Classification : equals : SecurityUpdates and AWS:PatchSummary.MissingCount : greater-than : 0  

![Maintainance Windows ](https://win309-reinvent.s3.us-east-2.amazonaws.com/Images/ec2sysman50.png)

4.  Try some more advanced search filters, can you identify any missing security updates on your instances?

  Congratulations, you have now completed all Lab activities  
