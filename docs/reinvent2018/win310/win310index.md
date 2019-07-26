# Home

Welcome to WIN310 - HANDS-ON: BUILDING A MIGRATION STRATEGY FOR SQL SERVER ON AWS

## Environment

Your account has the following resources already created for you in eu-west-1 (Ireland).  It was created with [this template](
https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/create/review?templateURL=https://s3-eu-west-1.amazonaws.com/win310/prerequisites.yml&stackName=win310). The AMI for the ONPREM server in eu-west-1 is **ami-08da693038d9ca4c4**.

![Architecture Diagram](prerequisites.png)

The on-prem server represents the source environment. We have also deployed SQL Server 2017 on both EC2 and RDS to be used as potential targets. Feel free add additional resources if needed. Notice that only the ONPREM server is accessible from the internet. Use this a jump box (i.e. bastion host). It has SQL Server Management Studio and the Schema Conversion Tool installed. Add anything else you want. 

All servers are joined to the example.com domain. The domain admin account is Admin@example.com and has access the SQL server instances on ONPREM. sqlsa@wxample.com is the service account for the SQL cluster WSFCNode1 and WSFCNode2. The RDS instance is domain joined, but no domain logins have been created. You can log into RDS and ONPREM using the SQL login sa. All users have the same password which will be shared during the workshop.   

## Helpful Links

[Best Practices for Deploying Microsoft SQL Server on AWS](https://d1.awsstatic.com/whitepapers/best-practices-for-deploying-microsoft-sql-server-on-aws.pdf)

[SQL Server on the AWS Cloud: Quick Start Reference Deployment](https://docs.aws.amazon.com/quickstart/latest/sql/welcome.html)

[SQL Server Performance on AWS](https://s3.amazonaws.com/aws-database-blog/artifacts/whitepapers/SQL-Server-Performance-on-AWS.pdf)

[RDS Native Backup and Restore](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/SQLServer.Procedural.Importing.html)

[Amazon Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)

[Database Migration Service](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html)

[Schema Conversion Tool](https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Welcome.html)

## Resources 

[Sample database on GitHub](https://github.com/brianjbeach/aws-database-migration-samples/tree/add-email/sqlserver/sampledb/v1)

[A 1GB full backup without tickets](https://s3-eu-west-1.amazonaws.com/win310/MSSQL2008R2_01.bak)

[A 9GB full backup with tickets](https://s3-eu-west-1.amazonaws.com/win310/MSSQL2008R2_03.bak)

