#There are three components you'll need to set up for native backup and restore:#

* An Amazon S3 bucket that contains the backup files to be restored (**_in the same region as the RDS Instance_**).
* An AWS Identity and Access Management (IAM) role to access the bucket.
* The **SQLSERVER_BACKUP_RESTORE** option added to an option group on your DB instance.
