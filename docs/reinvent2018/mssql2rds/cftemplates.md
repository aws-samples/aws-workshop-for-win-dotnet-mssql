##**Demo Template - <span style="color:orange">Source SQL Server 2008</span>**##
###_Inventory:_###
* SQL 2008 on Server 2008 R2 (with SSMS)
* Standalone  
* _Max Setup Time is around 10 mins_

s3 link:
[Demo_W2008R2SourceSQL.json](https://s3.amazonaws.com/sacrj-cftemplates-prod/templates/Demo_W2008R2SourceSQL.json)

---
***
##**Demo Template - <span style="color:orange">Target RDS - no Managed AD</span>**##
###_Inventory:_###
* EC2 w/ SSMS (as Jump Server)
* SQL RDS - MultiAZ not available in certain Regions
* _Max Setup time is around 25 mins (RDS Multi-AZ - 20+ Mins)_

s3 link:
[Demo_W162k16SSMS_RDSSQL-se_AZ.json](https://s3.amazonaws.com/sacrj-cftemplates-prod/templates/Demo_W162k16SSMS_RDSSQL-se_AZ.json)

##**Demo Template - <span style="color:orange">Target RDS - with Managed AD</span>**##
###_Inventory:_###
* EC2 w/SSMS - Domain Auto-joined (as Jump Server)
* SQL RDS - Domain Auto-joined, MultiAZ not available in certain Regions
* EC2 (Auto Domain Join) - Requires IAM Role and Instance Profile that has the AmazonEC2RoleforSSM Policy - **Provided by Template**
* RDS (Audo Domain Join) - Requires IAM Role that has the AmazonRDSDirectoryServiceAccess Policy - **Provided by Template**
* Auto-adds [domain]\admin user with elevated rights on SQL RDS
* _Max Setup time is around 1 hour (MAD - 30 Mins, RDS Multi-AZ - 20+ Mins)_

s3 link:
[Demo_W162k16SSMS_RDSSQL-se_AZ_MAD.json](https://s3.amazonaws.com/sacrj-cftemplates-prod/templates/Demo_W162k16SSMS_RDSSQL-se_AZ_MAD.json)