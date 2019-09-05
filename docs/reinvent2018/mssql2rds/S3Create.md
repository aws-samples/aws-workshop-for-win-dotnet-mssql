1.  Sign in to the AWS Management Console and open the Amazon S3 console at [https://console.aws.amazon.com/s3/](https://console.aws.amazon.com/s3/)  
2.  Choose **Create Bucket**  
![](./images/S3/S3Create.png)
3.	In the **Bucket Name** field, type a unique DNS-compliant name for your new bucket. (The example screen shot uses the bucket name admin-created. You cannot use this name because S3 bucket names must be unique.) Create your own bucket name using the follow naming guidelines:
	1.  The name must be unique across all existing bucket names in Amazon S3.
	2.  After you create the bucket you cannot change the name, so choose wisely.
	3.  Choose a bucket name that reflects the objects in the bucket because the bucket name is visible in the URL that points to the objects that you're going to put in your bucket.
4.	For Region, (for the purposes of this demo) **Choose the region where the Target RDS SQL Server resides**.
5.	Choose **Create**  
![](./images/S3/S3Choose.png)