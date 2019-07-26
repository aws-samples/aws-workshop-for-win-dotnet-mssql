# re:Invent 2018 - Architecting Active Directory in AWS

## Welcome


It is estimated that over 70% of our Enterprise customer workloads are based on Microsoft Windows. In most enterprises, Microsoft Active Directory (AD) is the foundation for authentication and security. Because Active Directory touches so many facets of a company's infrastructure, it is a vital component in any cloud migration strategy.

AWS Microsoft Active Directory is a full Microsoft Active Directory that provides greater compatibility with Microsoft products requiring integration. Customers can use it as a primary user directory in the AWS cloud for use with AD-aware applications such as SharePoint and Amazon RDS for SQL Server, or they use it as a resource directory by connecting it to their self-managed AD infrastructure. In this workshop, we are going to show you how easy it is to securely implement Active Directory in AWS, as well as discuss the different deployment options.

The structure of this Workshop involves showing you two Active Directory patterns commonly observed in the field, discussing their use cases, and then guiding you through implementing them inside a fully functional AWS account.

- Scenario 1 – Extending your on-premise AD domain into AWS using EC2 Instances.

- Scenario 2 - Implementing AWS Directory Services for Active Directory and creating a trust relationship between AWS and your on-premise AD Domain.

You can jump straight to the scenario that best fits your business, however, you should also have enough time to fully complete both scenarios in this workshop and if you complete both labs we've added a Bonus lab focusing on AWS Systems Manager. To make this possible, we have pre-configured an account with the assets you need.


As illustrated above, we have created two VPC’s in a single AWS Account. VPC01 represents your primary AWS VPC. It is what we would expect you to have in your own AWS VPC. We have also created an AWS Directory Services domain with a domain name of **CORP.EXAMPLE.COM** in this VPC. The reason for pre-creating the AWS Directory Service ahead of the workshop is to save ourselves the 20 minutes it takes to provision.

Since we do not have the ability to provide you with an on-premise environment for this workshop, we have placed all the servers we need in a separate VPC.  VPC02 simulates an on-premise environment with two servers already created. One server acting as an Active Directory Domain Controller for **ACME.COM** in a private subnet, the other with Active Directory Management Tools already installed. The on-premise to AWS communications are simulated by VPC peering between the two VPC’s.

We have also prepared two additional labs should you finish LABs A & B.   
LAB C steps you through Federation to the console using AWS Directory Services and LAB D takes a walkthrough of some key AWS Systems Manager functions that we think you'll use for your Microsoft Workloads in AWS.
