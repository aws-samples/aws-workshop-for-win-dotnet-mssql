---
title: "Lab: Configuring a SQL Server Failover Cluster Instance with Storage Spaces Direct and EBS"
---

Author: Sepehr Samiei

Draft version 0.1

Abstract
========

In this lab we will create a Storage Spaces Direct (S2D) cluster on Windows
Server 2016, and deploy a cluster of SQL Server Failover Cluster Instances on
top of the same cluster. Underneath S2D storage pool, we will use AWS EBS
volumes. SQL Server FCI on AWS requires BYOL, but going through activities in
this lab can be done using SQL Server Developer edition.

Introduction
============

Microsoft SQL Server offers many High Availability and Disaster Recovery (HA/DR)
requirements. Each of these is suited for specific requirements and business
needs. Always On Failover Cluster Instances is an HA capability that relies upon
usage of a single shared storage media, accessible by multiple SQL Server
instances. Although there are multiple SQL Server instances involved in FCI, but
only one process will be running at any point in time. Therefore, the shared
storage is only accessed and used by the single running (active) instance.

In case the active SQL Server instance in an FCI fails or stops for any reason,
one of the other nodes in FCI will start running and uses the same SQL Server
files stored on the shared storage media. When used with a Network Listener, the
failover will be transparent from applications and users point of view, although
applications with an open session would have to reopen their connection.

![](media/640821de7ee56ea6afc4de26120cc93f.png)

Always On FCI works at server level (SQL Server instance). This means, in the
event of a failover, all databases and other server-level objects will
simultaneously move to the new active instance. This could particularly be
beneficial for inter-dependent databases and applications that rely on
server-level objects.

In on-premises environments, SQL Server AO FCI is often used within a single
datacenter. This is due to the reliance on shared storage. The network latency
between different datacenters often makes deployment of a shared storage in a
stretch cluster impractical. This is one of the reasons this solution is
regarded as an HA solution at server, enclosure or rack level.

In AWS, because of the low-latency architecture of AWS Availability Zones, SQL
Server FCI is recommended in a multi-AZ deployment. This would be equivalent to
a multi-datacenter deployment on-premises, however, without negative impacts of
inter-DC network latency. Such an architecture promotes reliability of SQL
Server Always On FCI to datacenter level. In case of a disaster impacting an
entire AWS Availability Zone, SQL Server workloads in a multi-AZ architecture
will continue to run seamlessly.

![](media/0b67356e41ffc9f8fa0071b5938d6c97.png)

Lab Overview
============

In this lab we will use Windows Server 2016 Storage Spaces Direct (S2D) to
create shared storage for SQL Server FCI. We will first create two Windows EC2
instances in two different availability zones and join then to an Active
Directory Domain. Then we will create a Windows Server Failover Cluster (WSFC)
out of our two Windows instances. After that, S2D will be enabled on the WSFC.
On top of S2D storage pool, we’ll create a volume and add it to Cluster Shared
Volumes (CSV) so it will be available to both nodes in our cluster. Finally we
will install SQL Server FCI on each node.

Prerequisites
=============

For completing this lab, you need the following requirements prepared and
available:

1.  An AWS account

2.  An AWS IAM user with privileges to create and modify EC2 instances, Security
    Groups and Elastic Network Interfaces (ENI)

3.  A Virtual Private Cloud (VPC) in the selected region in your AWS account

4.  An Active Directory domain. You may have an AD infrastructure using one of
    the following options:

    1.  Use an existing AD environment on-premises and enable AWS AD Connect

    2.  Deploy AD Domain Controllers on EC2 instances

    3.  Use AWS Managed Directory Service for Microsoft AD

5.  An administrator account on your AD domain to allow new servers join your
    domain

Configuring network
===================

We are going to create a Windows Server Failover Cluster, enable S2D and deploy
SQL Server on top of it. For this purpose, we need to make sure all necessary
network ports are open and accessible to the nodes in our cluster. Following
table lists network port requirements:

| Group      | Protocol | Port Range    | Description                                                           |
|------------|----------|---------------|-----------------------------------------------------------------------|
| WSFC       | UDP      | 1024 - 65535  | Randomly allocated high UDP ports                                     |
|            | TCP      | 3343          | Cluster Service (This port is required during a node join operation.) |
|            | UDP      | 137           | Cluster Administrator                                                 |
|            | TCP      | 49152 - 65535 | TCP random port number                                                |
|            | TCP      | 135           | RPC                                                                   |
|            | UDP      | 3343          | Cluster Service                                                       |
|            | TCP      | 445           | SMB                                                                   |
|            | ICMP     | 0 - 65535     | Ping, required at cluster creation                                    |
| WinRM      | TCP      | 47001         | Listener                                                              |
|            | TCP      | 5986          | HTTPS for WinRM                                                       |
|            | TCP      | 5985          | HTTP for WinRM                                                        |
| SQL Server | TCP      | 1433          | SQL Server endpoint                                                   |
|            | UDP      | 1434          | SQL Server administration                                             |
| RDP        | TCP      | 3389          | Remote Desktop                                                        |

Follow these steps to create and configure your Security Groups in AWS:

1.  Go to AWS console, navigate to EC2 and select Security Groups.

2.  Select Create Security Group button

3.  Enter the first group name from above table (WSFC) in the security group
    name and description fields

4.  Select your target VPC

5.  Select Add Rule button

6.  Enter values from the above table into the added row

7.  Repeat steps 5 and 6 for all remaining rows in group WSFC

8.  Select Create button

Repeat above steps for the other three groups (WinRM and SQL Server). The target
for WSFC and WinRM has to be the nodes in the same cluster. Target for SQL
Server should also include any applications that need connection to SQL Server
(e.g. your test computer where you might be running SQL Server Management
Studio). RDP should be accessible to either your own computer or your bastion
host.

You have now created three security groups in your VPC. We will use these
security groups in following sections when we create EC2 instances.

Create Windows EC2 instances
============================

Storage Spaces Direct is supported on AWS EC2 Nitro platform instances. This
includes latest generation instance types such as C5, M5, R5 and M5d. In this
lab we will use M5 instances. Follow these steps to create two M5 EC2 instances:

1.  Go to EC2 console

2.  Select Launch Instance button

3.  Select Microsoft Windows Server 2016 Base from the quick start AMI list

4.  Select m5.xlarge for instance type and then select Next button

5.  In the instance details page, select your VPC, and target subnet. Notice, in
    some regions new instance types may not be available in all availability
    zones. If in the end of these steps you get a message about your selected
    instance type being unavailable, go back to this step and select a different
    availability zone.

6.  If you are using AWS AD Connect or AWS Directory Service for Microsoft AD,
    you can select your AD domain directly from instance details page. This will
    automatically join the Window instance to your AD domain.

7.  In the Add Storage page, add two new EBS volumes, each one 500 GB. In
    production, it is often recommended to use Provisioned IOPS (IO1) volume
    types. For this lab you can leave volume type as GP2. You can select Delete
    on Termination checkbox to make sure these EBS volumes are deleted after
    your lab activities are done and you decide to terminate your EC2 instances.

8.  In the Add Tags screen, add a tag as follows:

    1.  Key: Name

    2.  Value: MSSQL FCI

9.  In the Configure Security Group screen, change the selection to existing
    security group. Now check the three security groups that you had created in
    previous section.

10. Select Review and Launch

11. Select launch. You will be prompted to select a key pair for authentication.
    If you have an existing key pair, you can select it from the list. You can
    also create a new key pair directly from the same screen.

12. Select Launch Instances.

If you go back to EC2 console, you should see your new EC2 instance being
created for you. It may take a few minutes until the instance is available. In
the meantime, go through the same steps described above and create your second
EC2 instance. This time select a different subnet and availability zone.

When both instances are up and available, login to each instance and make sure
both are joined to your AD domain. If you are not using AWS AD Connect or AWS
Directory Service for Microsoft AD, you will have to manually join your
instances to AD domain.

Optionally you could also rename your Windows instances to meaningful names such
as fci-1 and fci-2. Following PowerShell commands can do that for you:

Rename-Computer -NewName "fci-1" -Force -Restart

Rename-Computer -NewName "fci-2" -Force -Restart

Run each line on its own target instance.

You should also either turn off Windows Firewall, or make sure all ports
mentioned in Security Group section are also opened on Windows firewall
settings.

Configure ENI secondary IP addresses
====================================

When you create a Windows Server Failover Cluster, in addition to the IP
addresses of each node in the cluster, you also need an IP address for WSFC
object itself. In a multi-subnet environment, you need a separate IP address for
each subnet. Windows supports two methods to provision these IP addresses:

1.  DHCP

2.  Static IP

DHCP is not recommended in production environments because availability of new
IP addresses at the time of failover is unpredictable. It is also not supported
on AWS VPC. This means you need to use static IP addresses. In order for these
static IP addresses to be routable to your EC2 instances, you would have to
directly assign them to an ENI that is attached to your EC2 instance.

Likewise, when you create SQL Server Always On Failover Cluster Instances, in
addition to the IP address of each SQL Server node, you also need to have an IP
address for the FCI object. Similar to WSFC, FCI also needs separate IP per each
subnet across which FCI is stretched. Since DHCP is not supported on Amazon VPC,
you’ll have to create a static IP and directly assign it to the ENI attached to
your EC2 instance.

This means you will have to create two secondary IP addresses per each ENI.
Since in this lab we have created two EC2 instances, it means you have to create
four secondary IP addresses.

Follow these steps to create secondary IP addresses:

1.  Go to EC2 console.

2.  Select one of the EC2 instances that you created in previous section

3.  On the description tab, select eth0 in front of Network Interfaces

4.  Click on the value of Interface IP. This would be a hyperlink that takes you
    to the Network Interfaces page.

5.  Select Actions \> Manage IP Addresses

6.  Select Assign new IP.

7.  You can either manually enter a new IP, or leave it to automatically assign
    an IP

8.  One more time select Assign new IP and either manually enter a new IP, or
    leave it to automatically assign an IP

9.  Select Yes, Update

Repeat the steps above for the second EC2 instance.

You have now created 4 secondary IP addresses and assigned 2 to each of your EC2
instances.

Create Windows Server Failover Cluster
======================================

Now that you have two Windows 2016 instances joined to the same AD domain, you
can create a WSFC. This is the easiest and most commonly used way to create a
WSFC. Windows Server 2016 also allows clusters to be across multiple domains or
standalone instances in a Workgroup (no AD domains). All of these scenarios are
supported on AWS, but in this lab we will focus on a cluster of instances joined
to the same domain.

First thing to do is to make sure Failover Clustering feature is installed and
enabled on both Windows nodes. Run the following PowerShell command on both
nodes:

Install-WindowsFeature -Name Failover-Clustering –IncludeManagementTools
-Restart

Once both nodes are ready, you can create the cluster. Login to one of the
instances using your AD administrator account and run the following PowerShell
commands:

\#Create new WSFC

\$ClusterName = 'fci-wsfc'

\$NodeNames = \@('fci-1','fci-2')

\$StaticIps = \@('10.0.3.178','10.0.4.79')

New-Cluster -Name \$ClusterName -Node \$NodeNames -StaticAddress \$StaticIps

Set-ClusterQuorum -CloudWitness -AccountName storageaccountname -AccessKey
youraccesskeyhere -Cluster \$ClusterName

Make sure the value of \$NodeNames is the same as your Windows machine names.
Use the first secondary IP address of each EC2 instance for \$StaticIps. Write
IP addresses in the same order as node names.

Since we are using only two Windows instances to form a cluster, we have to use
dynamic quorum. Otherwise, if one instance is failed, a majority vote will no
longer be available and the cluster also goes down. You can use a file share
witness or a cloud witness to enable dynamic quorum. Both are supported on
Windows EC2 instances in AWS. For more details, please refer to Microsoft
Windows documentation.

During cluster setup, you will receive warnings about network interfaces being a
single point of failure. Ignore these warnings, as these are for hardware
network interfaces. ENI in AWS VPC includes built-in fault tolerance.

You should now have a Windows Server Failover Cluster.

Enable Sotrage Spaces Direct
============================

Now that you have a WSFC, it is very easy to enable S2D. You do not need to
enable or mount any of the EBS volumes. Leave all EBS volumes as they are and
execute following cmdlet on one of the nodes to enable S2D on the entire
cluster:

Enable-ClusterStorageSpacesDirect

Alternatively you could run this simpler cmdlet:

Enable-ClusterS2D

This will enable S2D on the cluster and create a storage pool out of all the EBS
volumes attached to the nodes in your cluster. Once cmdlet is executed
successfully, you can use Failover Cluster Manager to visually see your storage
pool and create logical volumes for SQL Server on top of it. Alternatively you
could use following PowerShell cmdlets:

New-Volume -FriendlyName "MSSQL-Data" -FileSystem CSVFS_ReFS
-StoragePoolFriendlyName S2D\* -Size 700GB

New-Volume -FriendlyName "MSSQL-Software" -FileSystem CSVFS_ReFS
-StoragePoolFriendlyName S2D\* -Size 100GB

After executing these two PowerShell commands, you will have two Cluster Shared
Volumes, both accessible simultaneously from each of the nodes in the cluster.
You can see these volumes in the path C:\\ClusterStorage

Installing SQL Server Failover Cluster Instances
================================================

First you need to make SQL Server installation media available to both of the
nodes in your cluster. One way to do that is to copy the files on one of the
CSVs created in previous section. If you don’t have SQL Server installation
files available, you can download them from Microsoft website.

There are two possible options for installing SQL Server FCI:

1.  Option 1 (Integrated installation with Add Node): First Install SQL Server
    on the primary node (active node in WSFC) as a single node FCI cluster, and
    then install and add secondary nodes to the same cluster.

2.  Option 2 (Advanced/Enterprise installation): Run setup with Prepare Failover
    Cluster functionality on all nodes, then run Setup with Complete Failover
    Cluster functionality on the primary node (active node in WSFC).

In this lab we will choose first option. Follow these steps to install and
configure SQL Server FCI:

1.  Login to the primary node in your WSFC.

2.  Disable NetBIOS from Advanced TCP/IP Settings window, accessible from
    Ethernet Properties (Network and Sharing Center).

3.  Mount SQL Server installation media by double clicking on the iso file.

4.  Double-click on setup.exe to open SQL Server setup window

5.  Select **New SQL Server Failover cluster installation**

6.  Follow setup wizard as you would normally do

7.  Make sure the installation directory on all nodes is exactly the same path

8.  Enter a SQL Server Network Name as the network endpoint of your FCI. E.g.
    **ao-fci-ne**

9.  Enter SQL Server cluster resource group name, e.g. ao-fci-rg

10. Select shared disks that will be used by SQL Server FCI. In this lab this
    would be Cluster Virtual Disk (MSSQL-Data)

11. In Cluster Network Configuration page, select the row showing the subnet of
    the primary node, deselect DHCP and enter the second secondary IP address of
    the primary node in the Address box.

12. For SQL Server Database Engine Account Name, you would need a domain user
    with sufficient privileges. Best practice is to use a service principal
    account specifically created for this purpose.

13. Notice Startup Type of the SQL Server Database Engine service is set to
    Manual. This is because process start and stop is controlled by FCI and
    cannot be automatic anymore.

14. Follow the rest of the setup wizard and complete the setup process

When installation on the first node is completed, you have a working SQL Server
FCI. But at this point the FCI includes only a single node. Therefore it is not
really highly available. We have to add the second node to this cluster to
achieve real HA. To do this, follow these steps:

1.  Login to the second node.

2.  Double-click on the installation iso file and mount it.

3.  Execute setup.exe to open SQL Server setup window.

4.  Select **Add node to a SQL Server failover cluster**

5.  Follow setup wizard

6.  For Cluster Network Configuration, select the checkbox showing the subnet of
    the secondary node. Deselect DHCP and enter second secondary IP address of
    the secondary node. When you select Next button, setup will prompt you with
    a message asking you to confirm you want to have a multi-subnet failover
    cluster configuration. Select **Yes** and proceed to next step.

7.  The service principal account for SQL Server is already selected for this
    node. You should only enter the password.

8.  Complete the wizard and wait until installation is completed.

Congratulations! You have now successfully deployed SQL Server Always On FCI on
S2D using AWS EBS volumes. You can test your cluster by connecting to the FCI
endpoint (**ao-fci-ne.yourdomainname**).

Create a database, create some tables and enter some rows. Then go to AWS EC2
console and stop the primary instance (active node in your WSFC). This would
simulate a failure on EC2 instance, EC2 host, or the availability zone. Go back
to your Management Studio and try to connect to the same endpoint and check your
database and tables. Everything is still in place and accessible. You can also
make changes while that instance is down. After a while, bring the start the EC2
instance again. S2D will seamlessly synchronize the disks on the instance with
all the block changes. After some time you can stop the new primary node from
EC2 console. If you check the database, you should see all the changes are still
available.
