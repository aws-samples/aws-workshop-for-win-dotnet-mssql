
#### Summary: 

Acme Inc.'s supports an application with a very low Recovery Time Objective (RTO). The application sits on-premise in a single data-center. Currently the application uses SQL Server as the backend database. Your team supports this application but doesn't have budget or the experience running a SQL Server Always-On multi-region cluster. The team has decided to convert the database to Amazon Aurora and take advantage of the cross-region replication.

#### Suggested Technology:

* [RDS for SQL Server](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html)

* [RDS for Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Aurora.html)

* [Database Migration Service](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html)

* [Schema Conversion Tool](https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Welcome.html)

#### Schema Conversion Tool and Database Migration Service

The SCT is conducted between two heterogeneous databases, **source** SQL Server on EC2 and **target** Aurora RDS. 

![Lab scheme](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_Lab_Scheme.png)


You will need to follow these steps to complete a migration a SQL Server to Aurora migration. In the interest of time please use your EC2 instance you launched at the beginging of the day as your **source** SQL Server. On your EC2 instance you have SQL Server 2017 Developer Edition installed with a database called Acme.

1) Install and configure the Schema Conversion Tool (SCT) 
2) Launch an Amazon Aurora instance in RDS
3) Launch a Database Migration Service (DMS) instance in the same region as the RDS instance and your EC2 instance
4) Use the SCT to create a compataible schema for Amazon Aurora
5) Configure DMS to replicate data from the SQL Server running on your EC2 instance to the Amazon Aurora instance on RDS.

### Create a database migration project using the Schema Conversion Tool

Now that you have installed the AWS Schema Conversion Tool, the next step is to create a Database Migration Project using the tool.

1. With the Schema Conversion Tool, enter the following values into the form and then click Next. 

| Parameter | Value |
| --- | --- |
| Project Name | AWS Schema Conversion Tool Project1 |
| Location | C:\Users\Administrator\AWS Schema Conversion Tool\Projects |
| Database Type | Transactional Database (OLTP) |
| Source Database Engine | Microsoft SQL Server |
| Server Name | Localhost |
| Server Port | 1433 |
| Instance Name |  |
| User Name | awssct |
| Password | Password1 |
| Use SSL | Unchecked |
| Microsoft SQL Server Driver Path | C:\Users\Administrator\Desktop\RDS Workshop\sqljdbc_4.0\enu\sqljdbc4.jar |

![Create SCT project](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Create_DB_Migration_Project.png)

2. Select the dbo  schema to analyze and click Next. 

![Select schema](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Select_Schema.png)

3. Review the Database Migration Assessment Report and then click Next. 

![Review SCT report](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Review_Report.png)

4. Go to the AWS RDS Console, launch a new DB instance (Amazon Aurora) and copy the Cluster Endpoint

![RDS console](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_RDS_Console.png)

5. Go back to the Schema Conversion Tool; enter the following values into the form and then click Finish. 

| Parameter | Value |
| --- | ---|
| Target Database Engine | Amazon Aurora |
| Server Name | Cluster End Point from Step 9 without the :3306  |
| Server Port | 3306 |
| User Name | awssct |
| Password | Password1 |
| Use SSL | Unchecked |
| Amazon Aurora Driver Path | C:\Users\Administrator\Desktop\RDS Workshop\mysql-connector-java-5.1.39\mysql-connector-java-5.1.39-bin.jar |

![Finish SCT project creation](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Create_DB_Migration_Project_Finish.png)

### Migrate the schema using the Schema Conversion Tool

Now that you have created a new Database Migration Project, the next step is to actually migrate the schema of the SQL Server database to the Amazon Aurora database.

6. Items with a red exclamation mark next to them cannot be directly translated from the source to the target.  In this case, it includes the stored procedures and SQL scalar functions.  Uncheck these items.

![Migrating schema](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Migrating_Schema.png)

7. Right click on the Source database in the left panel and select Convert Schema. 

![Convert schema](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Convert_Schema.png)

8. When presented with the warning that only 3 of the 8 objects will be converted, click OK. 

![Schema OK](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Converted_Schema_OK.png)

9. When warned that objects may already exist in database, click Yes .

![Schema Yes](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Converted_Schema_Yes.png)

10. Right click on the DMSSourceDB_dbo schema in the right-hand panel and click Apply to database. 

![Apply schema](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Apply_Schema.png)

11. When prompted if you want to apply the schema, click Yes. 

![Apply schema yes](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Apply_Schema_Yes.png)

12. At this point, the schema has been applied to the target database. Expand the DMSSource_DB_dbo schema to see the tables.

![Schema review](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_SCT_Schema_Review.png)

### Database Migration Service (DMS)

AWS Database Migration Service helps you migrate databases to AWS easily and securely. The source database remains fully operational during the migration, minimizing downtime to applications that rely on the database. The AWS Database Migration Service can migrate your data to and from most widely used commercial and open-source databases. AWS Database Migration Service can also be used for continuous data replication with high availability.


### Migrate the source SQL database to the target RDS SQL database

Create a DMS Replication Instance for Database Migration Service. The replication instance initiates the connection between the source and target databases, transfers the data, and caches any changes that occur on the source database during the initial data load.

Click on https://console.aws.amazon.com/dms/home to launch the Database Migration Service screen.

![Create replication instance 2](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_create_replication_instance_2.png)

**1. Create the source and target endpoints**

After the replication instance is created, go to endpoints and click create endpoints 

Enter the Connection details for your source and target database endpoints. The source is the SQL Server database on EC2 instance and the target is the RDS SQL Server instance.

Make sure to select your replication instance created in the previous step.

Repeat the previous step to create the target endpoint.


**2. Create Replication Task**

Choose Tasks  from the left pane and click Create Task  as shown in the screen shot. Enter the following details.

![Create replication task](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_create_replication_task.png)

Make sure to set your task settings as show above and click **Create Task**. Now your database migration task starts running.

Go to Tasks and check the status of your Task. Once task is completed, your data should have been migrated to the target database.

![Create replication task 2](https://s3-us-west-2.amazonaws.com/migration-training-resources/migration-training-labs/latest/dms_lab/DMS_create_replication_task_2.png)

### Inspect the migrated RDS SQL database content

Make sure to log into the newly created SQL Server RDS instance using SQL Server Management Studio or any other tool you are familiar with and check to see that the  table data have migrated over.