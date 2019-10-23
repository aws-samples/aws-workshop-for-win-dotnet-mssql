In this session we will configure required IAM roles and permissions for Systems
Manager OpsCenter, configure basic rules and use these rules to monitor and
report on issues related to Auto Scaling group events.

We will then use Systems Manager Automation to remediate the issue with the Auto
Scaling group configuration.

Setup the basic rules in OpsCenter
----------------------------------

### Create OpsCenter IAM Role

1.  Sign in to the AWS Management Console and open the IAM console
    at <https://console.aws.amazon.com/iam/>.

2.  In the navigation pane, choose **Policies**.

3.  Choose **Create policy**.

4.  Choose the **JSON** tab.

5.  Replace the default content with the following:

>   {

>   "Version": "2012-10-17",

>   "Statement": [

>   {

>   "Effect": "Allow",

>   "Action": "ssm:CreateOpsItem",

>   "Resource": "\*"

>   }

>   ]

>   }

1.  Choose **Review policy**.

2.  On the **Review policy** page, for **Name**, enter a name. For
    example: **OpsCenter-CWE-Policy**.

3.  For **Description**, enter information about this policy that identifies its
    purpose.

>   For example: Allow OpsCenter to create OpsItems

1.  Choose **Create policy**.

Use the following procedure to create an IAM role that enables CloudWatch Events
to automatically create OpsItems in OpsCenter.

**To create an OpsCenter role for CloudWatch Events**

1.  Sign in to the AWS Management Console and open the IAM console
    at <https://console.aws.amazon.com/iam/>.

2.  In the navigation pane, choose **Roles**.

3.  Choose **Create role**.

4.  On the **Create role** page, under **Select type of trusted entity**, verify
    that **AWS service** is selected.

5.  Under **Choose the service that will use this role**, choose **CloudWatch
    Events**.

6.  Under **Select your use case**, choose **CloudWatch Events**, and then
    choose **Next: Permissions**.

7.  On the **Permissions** page, leave the default settings and choose **Next:
    Tags**.

8.  (Optional) On the **Tags** page, specify key-value tag pairs, and then
    choose **Next: Review**.

9.  On the **Review** page, for **Role name**, enter a name. For
    example: **OpsItem-CWE-Role**.

10. For **Description**, either leave the default description or enter
    information about this role that identifies its purpose.

11. Choose **Create role**.

Use the following procedure to attach the policy you created earlier to the role
you just created.

**To attach the OpsCenter policy to the OpsCenter role for CloudWatch Events**

1.  Sign in to the AWS Management Console and open the IAM console
    at <https://console.aws.amazon.com/iam/>.

2.  In the navigation pane, choose **Roles**.

3.  Locate the role you just created.

4.  Choose the name of the role to open the **Summary** page.

5.  (Optional) You can detach the policies that were automatically assigned to
    this role when you created it. Choose the **X** beside each policy to detach
    it.

6.  Choose **Attach policies**.

7.  On the **Attach permissions** page, locate the OpsCenter policy that you
    created earlier.

8.  Choose this policy, and then choose **Attach policy**. IAM returns you to
    the **Roles** page.

9.  Choose the name of the role to open the **Summary** page.

10. Copy the role ARN. You must specify this ARN when you configure OpsCenter to
    automatically create OpsItems by using CloudWatch Events..

CloudWatch Events now has the required permissions to automatically create
OpsItems in OpsCenter.

### Enable OpsCenter Basic Rules

1.  In AWS Management Console select Systems Manager from the Services menu

2.  Select OpsCenter from the menu on the left

    ![](media/b7714ce12aaeadaead47d847dcc2ba5a.png)

3.  In the OpsCenter console select Get Started

4.  In the Basic Setup section scroll down to the bottom of the screen and paste
    the IAM role ARN that was created in the previous section.

5.  Select **Create basic OpsItem rules**

Deploy the CFN stack to create custom AMI.
------------------------------------------

The following CloudFormation stack will launch a Linux instance and will create
a custom AMI based on this instance. It will provide a custom AMI ID as an
output of the stack.

1.  In AWS Management Console select CloudFormation from the Services menu

2.  Select **Create Stack**

3.  Specify template source [link](https://awsentworkshops.com/reinvent2019/MGT412/createInstance_image.yaml "CloudFormation Template"

4.  Select **Next**

5.  On the **Specify Stack details** screen provide the stack name and click
    **Next**

6.  Click **Next** on the **Configure Stack Options** screen**.**

7.  On the **Review** screen check the box to acknowledge that AWS
    CloudFormation may create IAM resources and select **Create Stack.**

8.  The stack will take approximately 5 minutes to complete. After the stack is
    completed, select the **Outputs** tab and note the AMI ID created by the
    CloudFormation (AMI value ami-xxxxxxxxx in the output below)

    ![](media/dd0441dfee216820328fff24e8e27271.png)

Deploy the CFN stack to launch an Auto-Scaling Group
----------------------------------------------------

This CloudFormation template will launch an Auto-Scaling group which will be
monitored by OpsCenter.

1.  In AWS Management Console select CloudFormation from the Services menu

2.  Select **Create Stack**

3.  Specify template source *ASGTemplate.yaml* [link](https://awsentworkshops.com/reinvent2019/MGT412/ASGTemplate.yml "CloudFormation Template"

4.  On the **Specify Stack details** screen provide the stack name and the
    custom AMI ID that you created previously. Click Next

5.  On the Configure Stack Options screen in the **Tags** section provide the
    **Name** tag with **Value**. Click **Next** on the bottom of this screen.

![](media/6c62a5bb4ff330f33f2195719ad1e0fd.png)

1.  Click **Create Stack** at the bottom of the **Review Stack** screen

2.  Wait until the stack is created.

3.  You can validate that ASG has been created and the single instance has been
    launched by viewing the instance and the ASG in EC2 console.

The created stack deploys and Auto-scaling Group as well as SSM Document that we
will use later to remediate issues identified by the OpsCenter.

### Enable AWS Config in your Account

1.  Open the Config console from the Services menu and select **Get Started**
    button

2.  Click **Next** on the **Settings** screen

3.  Click **Next** on the **AWS Config** rules screen

4.  Click **Confirm** on the **Review** screen

5.  Setting up AWS Config will take a few seconds. You will be returned to
    **Config Dashboard** screen.

### Create CloudWatch Alarm

1.  In CloudWatch console select **Alarms** from the menu on the left

2.  Click **Create alarm**

3.  On the **Specify metric and conditions** screen click **Select metric**

4.  On the **Select metric** screen select **Auto Scaling** – **Group Metrics**
    and check the box next to **GroupTotalInstances** metric name

![](media/42c4a3a2859eff92f6b70e1e0ac466c5.png)

1.  Click Select metric

2.  On the specify metric and conditions screen scroll down to Conditions and
    select **Threshold type – Static, Whenever GroupTotalInstances is… - Lower**
    than **2.** Click **Next**

3.  On the **Notifications** screen click **Remove** in the **Notification**
    section

![](media/52eb2e5b2f1bd82671e1d462421d0da5.png)

We do not need to create notifications when the alarm is triggered.

Click **Next**

1.  On the **Add description** screen provide a unique alarm name, e.g
    **BelowDesiredCapacity** and click **Next**

2.  On the **Preview and create** screen scroll to the bottom and click **Create
    Alarm**

    We have created a CloudWatch alrm which will be triggered if the number of
    instances in the Auto Scaling group falls below 2

Demonstrate the Creation of OpsItems
------------------------------------

1.  Open the EC2 console

2.  Verify that the Auto Scaling group exists by selecting Auto Scaling Groups
    from the menu on the left

    ![](media/062181c0d1108a14e0f9dca2f6a95e16.png)

    Verify that the **Instance** count and **Desired** count are set to the
    number 2

3.  Select **AMI** menu item under **Images** menu

![](media/87190a05eb2a025fa7c23548bed48c8d.png)

1.  Deregister the custom AMI that we created earlier and which was used to
    create the Auto Scaling group by selecting Actions – Deregister from the
    pull down menu

![](media/29e1bb9bc397135616fb38da83552163.png)

1.  Confirm the operation by clicking Continue on the **Deregister** screen.

2.  Click on the **Instances** menu item under **Instances** menu on the left
    side

3.  Select one of the instances belonging to the Auto Scaling Group, then select
    **Instance State – Terminate** from the **Actions** pull down menu.

![](media/a1c2524b56275d38a9106cdaf5d1f562.png)

1.  On **Terminate Instances** screen confirm termination by clicking **Yes,
    Terminate**

    The instance should enter the **shutting-down** state.

By terminating the instance we brought the total instance count below the
desired instance count of 2 which should trigger the Cloudwatch alarm and auto
scaling event. However, since we deleted the custom AMI, the Auto Scaling should
fail and the failure will be captured by OpsCenter. In the next section we will
examine the OpsItem created by OpsCenter in response to the Auto Scaling
failure.

Explore OpsItems
----------------

1.  Open the **Systems Manager** console from the **Services** menu and select
    OpsCenter

![](media/5ecd6c18a91caa81123a34cda0267dff.png)

1.  In the Summary Screen you should see the EC2 Auto Scaling source with 1
    OpsItem.

2.  Click on 1 next to the EC2 Auto Scaling source

3.  In the **OpsItems** screen you should see the OpsItem ID with **Auto Scaling
    EC2 instance launch failure** title.

4.  Click on the **OpsItem ID** to open the details of the **Auto Scaling EC2
    instance launch failure** OpsItem.

5.  Scroll down to the Operational data section and open the section by clicking
    on the black triangle

    ![](media/4a9a079db342c8c44daaabfcc6888d25.png)

    As you can see OpsItem contains detailed explanation of the event that
    triggered the failure and the reason for the failure.

6.  Scroll up and click on the Resource ARN

    ![](media/d7bb5d778dd731b2b6e78ad6c95ee646.png)

7.  In the Related Resource details screen click on Expand all to display all
    related resources

8.  Examine the following sections of the OpsItem Related resource:

-   Tags

-   Current CloudWatch alarms

-   Details from AWS Config

-   CloudTrail Logs

-   CloudFormation stack resources

Resolve the issue by running SSM Automation Document
----------------------------------------------------

Now we will resolve the issue of not being able to launch the instance from the
deleted AMI by re-creating the AMI and updating the Launch Configuration.

1.  Open the Systems Manager console

2.  Select **Automation** from the menu on the left.

3.  Select **Execute Automation**

4.  In the **Choose document** screen select Owned by me

5.  Select the document that was created by the CloudFormation

6.  Select **Execute Automation**

7.  Leave the **Simple Execution** (default) and provide the Auto Scaling Group
    name in the **Input parameters** section

    ![](media/ca613a3394ae9cadbc77e876007b8947.png)

8.  Click **Execute**

    Automation will run the document that remediates the missing AMI by creating
    the new AMI from running instance and updating the Auto Scaling Launch
    configuration. When the execution completes, you can see that there are 2
    running instances in the Auto Scaling group.

    ![](media/78fcbb8f77b1de190fb14c0d983da4aa.png)

    You can also see that CoudWatch alarm changes state to OK in a few minutes

    ![](media/50e09e6f06a816b615f36d7379d4cebf.png)
