![](media/c708e45f6ac348956a43834de301fb32.png)

>   **Database Migration Workshop**

>   Lab 2

>   AWS Database Migration Service (DMS) Microsoft SQL Server

November 2019

Overview 
=========

>   AWS Database Migration Service (DMS) helps you migrate databases to AWS
>   easily and securely. The source database remains fully operational during
>   the migration, minimizing downtime to applications that rely on the
>   database. AWS DMS can migrate your data to and from most widely used
>   commercial and open-source databases. The service supports homogenous
>   migrations such as SQL Server to SQL Server, as well as heterogeneous
>   migrations between different database platforms, such as SQL Server to
>   Amazon Aurora MySQL or Oracle to Amazon Aurora PostgreSQL. AWS DMS can also
>   be used for continuous data replication with high-availability.

>   This lab demonstrates how you can use AWS Database Migration Service (DMS)
>   to migrate data from the source Microsoft SQL Server running on an Amazon
>   EC2 instance to the target SQL Server running on Amazon RDS. Additionally,
>   you will use AWS DMS to continually replicate database changes from the
>   source database to the target database.

![](media/5418b92d0c6f1aa5141412601ccff95d.jpg)

Connecting to the Environment
=============================

![](media/0b66a375c847696b8d16a52efb49e9f0.png)

Sign in to your AWS Account provided by your facilitator and review the
CloudFormation stack within N Virginia Region [us-east-1].

>   <https://us-east-1.console.aws.amazon.com/cloudformation>

>   Review the important output values:

1.  SourceSQLPublicIP

2.  RDSJumpServerIP

3.  TargetRDSSQLEndpointDns

>   The following steps provide instructions to migrate existing data from the
>   source Microsoft SQL Server database running on an EC2 instance to a SQL
>   Server database running on Amazon RDS. In this exercise you perform the
>   following tasks:

-   Connect the source SQL Server running on an EC2 instance

-   Configure the source database for replication

-   Configure the target database for migration

-   Create an AWS DMS Replication Instance

-   Create AWS DMS source and target endpoints

-   Create and run your AWS DMS migration task

Connecting to Source SQL Server on EC2
======================================

Connecting to SQL 2008 via SSMS

1.  Go and click on the SSMS icon on the Desktop, or go to Start and click on
    the Microsoft SQL Server management studio.

    ![http://mssql2rds.reinvent-session.com/images/sourceEC2/SourceSSMS.png](media/ef8be94ddc8f9ab97ad90fa7ed79719a.png)

2.  The first time you run SSMS, the Connect to Server window opens. If it
    doesn't open, you can open it manually by selecting Object Explorer \>
    Connect \> Database Engine.

    ![http://mssql2rds.reinvent-session.com/images/sourceEC2/ssmsinitial.png](media/a72da5d6f26c753b6445961e7cd0c3ea.png)

3.  In the *Connect to Server* window, do the following:

4.  For Server type, select *Database Engine* (usually the default option).

5.  For Server name, enter the name of your SQL Server instance. (For this demo,
    since the DB engine resides in the same server, you can specify
    "**localhost**", "**.**", or the **hostname**).

    ![http://mssql2rds.reinvent-session.com/images/sourceEC2/ssmsconnect.png](media/73d7e01050854e598200e363ce925852.png)

6.  For Authentication, select **Windows Authentication**.

7.  After you've completed all the fields, select **Connect**

8.  Example of successful connection

![http://mssql2rds.reinvent-session.com/images/sourceEC2/ssmsconnectverify.png](media/dd68251b08782d8fe4ef535b04f911f8.png)

Configuring the Source database for replication
===============================================

>   When migrating your Microsoft SQL Server database using AWS DMS, you can
>   choose to **migrate existing data only**, migrate existing data and
>   replicate ongoing changes, or migrate existing data and use change data
>   capture (CDC) to replicate ongoing changes.

>   Migrating only the existing data does not require any configuration on the
>   source SQL Server database. However, to migrate existing data and replicate
>   ongoing changes, you need to either enable **MS-REPLICATION**, or
>   **MS-CDC**. For this lab , we will be using **migrate existing data only**

1.  Change sa account password

    ![](media/50e8581cf89b84f36d7f0756b43176d0.png)

    1.  From within **SQL Server Management Studio**, navigate to **Security**

    2.  Expand Security.

    3.  Double click on sa account.

    4.  Change the password to NYCsql2019!!!

        ![](media/a230c55d2220e33ea65cbe80773c95f0.png)

Configuring the Target database for migration
=============================================

**Use EC2 Jump Server to connect RDS Instance**

1.  Go to **Remote Desktop Connection**

2.  Specify the **Public IP** or **Public DNS** of the Target EC2 Jump Server as
    the **Computer Name**

3.  Username: *localhost\\administrator* 

4.  Password: *NYCsql2019!!!*

5.  Click on **Connect**

![http://mssql2rds.reinvent-session.com/images/TargetRDS/TargetConnect1.png](media/160d1572b6a7e1a3e711c8c0f1abe249.png)

Connecting to RDS Instance via SSMS on Jump Server
==================================================

1.  Go and click on the SSMS icon on the Desktop, or go to Start and click on
    the Microsoft SQL Server management studio.

    ![http://mssql2rds.reinvent-session.com/images/sourceEC2/SourceSSMS.png](media/ef8be94ddc8f9ab97ad90fa7ed79719a.png)

2.  The first time you run SSMS, the Connect to Server window opens. If it
    doesn't open, you can open it manually by selecting Object Explorer \>
    Connect \> Database Engine.

    ![http://mssql2rds.reinvent-session.com/images/sourceEC2/ssmsinitial.png](media/a72da5d6f26c753b6445961e7cd0c3ea.png)

3.  In the *Connect to Server* window, do the following:

4.  For Server type, select *Database Engine* (usually the default option).

5.  For Server name, enter the name of your RDS SQL Server instance. ( RDS
    Endpoint)

    ![](media/0bc9cccf169cadf43d83a2acc4e04126.png)

6.  For Authentication, select **SQL Authentication** and use
    Administrator/NYCsql2019!!!

    ![http://mssql2rds.reinvent-session.com/images/TargetRDS/TargetSSMS5.png](media/2658aa2e55b581538138b39dd6637e58.png)

7.  After you've completed all the fields, select **Connect**

8.  Example of successful connection

    ![](media/64a2e4c3f61323fa878fb1de4edd581b.png)

9.  Open a **New Query** window.

10. Run the following script to create a target database **dms_recovery** on RDS
    SQL Server.

>   The target database **(dms_recovery)** has now been created.

>   Please return to the **AWS Management Console**.

Create Replication Instance
===========================

>   The following illustration shows a high-level view of the migration process.

![](media/ca7f4c8168c6a3b657f41555929aeddb.png)

>   An AWS DMS replication instance performs the actual data migration between
>   source and target. The replication instance also caches the transaction logs
>   during the migration. The amount of CPU and memory capacity a replication
>   instance influences the overall time that is required for the migration.

1.  Click on *https://console.aws.amazon.com/dms/* to launch the Database
    Migration Service.

2.  On the left-hand menu click on **Replication Instances**. This will launch
    the Replication instance screen.

3.  Click on the Create replication instance button on the top right side.

4.  Enter the following information for the **Replication Instance**. Then,
    Click on **Create** button.

| **Parameter**                      | **Value**                          |
|------------------------------------|------------------------------------|
| Name                               | DMSReplication                     |
| Description                        | Replication server for the DMS Lab |
| Instance Class                     | dms.t2.medium                      |
| Engine version                     | Leave the default value            |
| Allocated storage (GB)             | 50                                 |
| VPC                                | **\< choose Target RDS VPC ID \>** |
| Multi-AZ                           | No                                 |
| Publicly accessible                | No                                 |
| Advanced -\> VPC Security Group(s) | \< RDSInstanceSecurityGroup \>     |

*NOTE: Creating replication instance will take several minutes. While waiting
for the replication instance to be created, you can specify the source and
target database endpoints in the next steps. However, test connectivity only
after the replication instance has been created, because the replication
instance is used in the connection.*

![](media/8357a3be77b6a5d8df50cec86d6df79c.png)

Create Source and Target Endpoints
==================================

>   Now that you have a replication instance, you need to create source and
>   target endpoints for the sample database.

1.  Click on the **Endpoints** link on the left, and then click on **Create
    endpoint** on the top right corner.

![](media/3817e5e6da7488d1f6305ac0272c40a7.jpg)

1.  Enter the following information to create an endpoint for the source
    **dms_sample**

>   database:

| **Parameter**        | **Value**                                         |
|----------------------|---------------------------------------------------|
| Endpoint Type        | Source endpoint                                   |
| Endpoint Identifier  | sqlserver-source                                  |
| Source Engine        | sqlserver                                         |
| Server Name          | **\< SourceSQLServerPrivateIP \> 10.0.0.x range** |
| Port                 | 1433                                              |
| SSL Mode             | none                                              |
| User Name            | sa                                                |
| Password             | NYCsql2019!!!                                     |
| Database Name        | Credit or Sales                                   |
| VPC                  | **\<VPC ID from Environment Setup Step\>**        |
| Replication Instance | DMSReplication                                    |

1.  Once the information has been entered, click **Run Test**. When the status
    turns to

>   **successful**, click **Save**.

![](media/89a5d1606eaea05896320e1289b4e627.jpg)

1.  Create another endpoint for the **Target RDS Database (dms_recovery)** using
    the following values:

| **Parameter**          | **Value**                                  |
|------------------------|--------------------------------------------|
| Endpoint Type          | Target endpoint                            |
| Select RDS DB instance | Check                                      |
| RDS Instance           | **\< Stack Name \>-TargetSQLServer**       |
| Endpoint Identifier    | sqlserver-target                           |
| Source Engine          | sqlserver                                  |
| Server Name            | **\< TargetSqlServerEndpoint \>**          |
| Port                   | 1433                                       |
| SSL Mode               | none                                       |
| User Name              | Administrator                              |
| Password               | NYCsql2019!!!                              |
| Database Name          | dms_recovery                               |
| VPC                    | **\< VPC ID for Target RDS SQL Server \>** |
| Replication Instance   | DMSReplication                             |

2.  Once the information has been entered, click **Run Test**. When the status
    turns to

>   **successful**, click **Create endpoint**.

![](media/bde8488d2e0046f837b8446e7754d19e.jpg)

Create a database migration task
================================

>   In order to migrate data from source database to target database you need to
>   create a transfer task.

1.  Click on **Database migration tasks** on the left-hand menu, then click on
    the **Create task**

>   button on the top right corner.

![](media/7ad2bee9ece8c93158a3ef6ce3864b91.jpg)

1.  Create a data migration task with the following values for migrating the
    **dms_sample**

>   database.

| **Parameter**                       | **Value**                      |
|-------------------------------------|--------------------------------|
| Task identifier                     | SampleMigrationTask            |
| Replication instance                | DMSReplication                 |
| Source database endpoint            | sqlserver-source               |
| Target database endpoint            | sqlserver-target               |
| Migration type                      | Migrate existing data only     |
| Start task on create                | Checked                        |
| CDC stop mode                       | Don’t use custom CDC stop mode |
| Target table preparation mode       | Do nothing                     |
| Stop task after full load completes | Don’t stop                     |
| Include LOB columns in replication  | Limited LOB mode               |
| Max LOB size (KB)                   | 32                             |
| Enable validation                   | Unchecked                      |
| Enable CloudWatch logs              | Checked                        |

1.  Expand the Table mappings section, and select **Guided UI** for the editing
    mode.

2.  Click on **Add new selection rule** button and enter the following values in
    the form:

| **Parameter** | **Value** |
|---------------|-----------|
| Schema        | dbo       |
| Table name    | %         |
| Action        | Include   |

>   NOTE: If the Create Task screen does not recognize any schemas, make sure to
>   go back to endpoints screen and click on your endpoint. Scroll to the bottom
>   of the page and click on **Refresh Button (⟳)** in the **Schemas** section.

>   If your schemas still do not show up on the Create Task screen, click on the
>   Guided tab and manually select **‘**dbo’ schema and all tables.

![](media/5e96c53e5a3e22006213a3188d595b3b.jpg)

1.  After entering the values click on **Create task**.

2.  At this point, the task starts running and replicating data from the
    dms_sample database running on EC2 to the Amazon RDS SQL Server instance.

![](media/d62efc3be6b9f92928480cb275c8382b.jpg)

1.  Once it completes you will see the status **Load Complete.**

2.  **Inspect the content by connecting to target RDS instance using
    Jumpserver.**

Summary 
========

>   This lab demonstrated how easy it is to migrate the data from a Microsoft
>   SQL Server running to an Amazon RDS SQL Server using the AWS Database
>   Migration Service (DMS).

Document revisions
==================

| Date          | Change        |
|---------------|---------------|
| November 2019 | Initial Draft |
