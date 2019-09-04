Prerequisites (What has already been configured)
================================================


-   Create a virtual private cloud (VPC) with one public subnet and two private
    subnets. A third, private subnet in a different AZ is required for the AWS Directory.

-   Create an AWS Managed Microsoft AD.

-   Create an IAM role granting AmazonEC2RoleforSSM or SSMFullAccess to Seamless Domain join the
    instances.

-   Launch one t3.medium in the Public Subnet and domain join.

-   Launch two i3.4xlarge instances one in each private Subnet and Domain join.

-   Correct/update computer names.

-   Assign secondary <a href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/MultipleIP.html" target="_blank">IPs</a> to i3 instances

-   Install the File Services and Failover-Clustering Windows features with the
    management tools on cluster nodes. Install only failover management tools on
    ADMx

-   Confiure networking for cluster performance (RSS)

-   Increase storage space I/O timeout value to 30 seconds (recommended when
    configured into a guest cluster).

-   Test, create, and verify the Windows Server Failover Cluster (WSFC)

-   Create and Configure a File Share witness for Quorum

-   The prequsites can be found in the AWS doc <a href="https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-tutorial-s2d.html" target="_blank">tutorial</a>, steps 1 -3 have been completed. This guide starts at step 4.
