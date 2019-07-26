# Bonus Exercises

If you have finished the other exercises and want something else to work on, here are a few ideas. There are no step-by-step instructions, but you can do it.

## Database Migration Service (DMS)

AWS Database Migration Service (AWS DMS) is a cloud service that makes it easy to migrate relational databases, data warehouses, NoSQL databases, and other types of data stores. You might want to use DMS rather than a backup/restore minimize the outage needed during the migration.

Migrate the dms_sample from the ONPREM server to RDS using DMS. Read the [getting started guide](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_GettingStarted.html).

## Simple Email Service (SES)

Amazon Simple Email Service (Amazon SES) is a cloud-based email sending service designed to help digital marketers and application developers send marketing, notification, and transactional emails. It is a reliable, cost-effective service for businesses of all sizes that use email to keep in contact with their customers. 

RDS does not support SQL Mail. If we choose RDS, we need an alternative method for sending emails. One alternative is to use SES. Create a lambda function the reads from the **confirmation_email_queue**, send emails using SES, and updated the **ticket_purchase_hist** table to indicate the email has been sent. Read [Building Lambda Functions with C#](https://docs.aws.amazon.com/lambda/latest/dg/dotnet-programming-model.html) and [Configuring a Lambda Function to Access Resources in an Amazon VPC](https://docs.aws.amazon.com/lambda/latest/dg/vpc.html).