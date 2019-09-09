Lab: Using Visual Studio to Deploy an ASP.NET Web App to AWS with Elastic
Beanstalk

Author: Anil Erduran

Draft version 0.1

Abstract

In this lab, you will configure your Visual Studio Environment and use “Publish
to Elastic Beanstalk” wizard, provided as part of the Toolkit for Visual Studio,
to deploy a traditional ASP.NET web application to AWS Beanstalk.

Introduction

AWS Elastic Beanstalk is an easy-to-use service for deploying and scaling web
applications and services developed with Java, .NET, PHP, Node.js, Python, Ruby,
Go, and Docker on familiar servers such as Apache, Nginx, Passenger, and IIS.

You can simply upload your code and Elastic Beanstalk automatically handles the
deployment, from capacity provisioning, load balancing, auto-scaling to
application health monitoring. At the same time, you retain full control over
the AWS resources powering your application and can access the underlying
resources at any time.

The AWS Toolkit for Visual Studio is an extension for Microsoft Visual Studio
running on Microsoft Windows that makes it easier for developers to develop,
debug, and deploy .NET applications using Amazon Web Services. With the AWS
Toolkit for Visual Studio, you'll be able to get started faster and be more
productive when building AWS applications.

You can easily use the AWS Toolkit for Visual Studio to develop, debug, and then
deploy your .NET web applications using a web application template. Then you can
use Visual Studio to build and run your application locally before deploying to
AWS Elastic Beanstalk

Prerequisites

To complete the lab, you need the following requirements:

-   Microsoft Visual Studio versions 2013 and later. (including Community
    editions).

-   An AWS Account

-   An AWS IAM user with privileges to create/modify AWS Elastic Beanstalk
    environments

-   Amazon EC2 key pair created for the selected region

Setting Up the AWS Toolkit for Visual Studio

In this task, you will configure AWS Toolkit for Visual Studio. The Toolkit for
Visual Studio is distributed in the Visual Studio Marketplace. You can also
install and update the toolkit using the Extensions and Updates dialog within
Visual Studio.

-   Navigate to the page [AWS Toolkit for Visual
    Studio](https://aws.amazon.com/visualstudio).

-   In the Download section, choose Toolkit for Visual Studio to download the
    installer.

-   To start the installation, run the downloaded installer and follow the
    instructions.

Before you can use the Toolkit for Visual Studio, you must provide one or more
sets of valid AWS credentials. These credentials allow you to access your AWS
resources through the Toolkit for Visual Studio. They're also used to sign
programmatic web services requests, so AWS can verify that the request comes
from an authorized source.

You will be creating a new IAM users for the purpose of this lab.

-   Navigate to the [AWS IAM Console](https://console.aws.amazon.com/iam/home)

-   Click **Users** on the left navigation pane click “**Add User**”

-   Provide a user name and select “**Programmatic Access**” as the Access Type.
    Click “**Next:Permissions**”

-   On the **Set Permission** dashboard, click “**Attach existing policies
    directly**” and select “**AWSElasticBeanstalkFullAccess**”. This policy
    provides full access to AWS Elastic Beanstalk and underlying services that
    it requires such as S3 and EC2. Click “**Next:Review**”

-   On the review page, click **Create User**.

-   Once the user is created, click “**Download .csv**” button to download csv
    file including access Key ID and Secret Access Key.

![](media/be7937919c23a096f022c872c78c17a5.png)

Now you can create a new profile within the Visual Studio:

-   Open **Visual Studio**, on the **View** menu, choose **AWS Explorer**.

-   Choose the **New Account Profile** icon to the right of the **Profile**
    list.

![](media/6a4dbcc3afa8618848e636ba0b404af5.png)

-   In the **New Account Profile** dialog box, following fields are required:

    -   Profile Name:

    -   Access Key ID:

    -   Secret Access Key:

-   Provide a Profile Name and then click **Import from CSV file** and choose
    the CSV file you downloaded in previous step. Click **OK**

-   Make sure new profile is created in **AWS Explorer.**

![](media/9c226d56cdc6157dde190475e8eb74a1.png)

Creating a Sample Web Application Project

In this task, you will be creating a new ASP.NET Web Application within Visual
Studio

-   In Visual Studio, from the File menu, choose New, and then choose Project.

-   In the navigation pane of the New Project dialog box, expand Installed,
    expand Templates, expand Visual C\#, and then choose Web.

-   Choose the ASP.NET Web Application template.

![](media/388419a674e5379a8e05ffea9dc010d7.png)

-   In the name box, type AWSEbWebAppDemo

-   In the Location box, type the path to a solution folder on your development
    machine. Choose OK.

In the next screen, you will be prompted by another wizard. Choose “Web API” and
click OK.

![](media/f6db941af5f30acdb9208a15fc4d9467.png)

Visual Studio will create a Web API solution and project based on the ASP.NET
Web Application project template. Visual Studio will then display Solution
Explorer where the new solution and project appear.

![](media/ae3a1276d3693c6a94f532eb54fa5dae.png)

Deploying Sample Web Application by Using the Publish to Elastic Beanstalk
Wizard

In this part, you will be using “Publish to Elastic Beanstalk Wizard” within AWS
Visual Studio extension to publish the sample ASP.NET Web Application to AWS
Elastic Beanstalk.

-   In Solution Explorer, open the context (right-click) menu for the
    AWSEbWebAppDemo project folder for the project you created in the previous
    section and choose Publish to AWS Elastic Beanstalk.

![](media/52bd08b8ead3419eae3582055942dfdc.png)

In the next steps you will be configuring AWS Elastic Beanstalk properties.

**Application:**

-   In Profile, from the Account profile to use for deployment drop-down list,
    choose the AWS account profile you want to use for the deployment.

-   From the Region drop-down list, choose the region to which you want Elastic
    Beanstalk to deploy the application

-   In Deployment Target, choose “Create a new application environment”. Choose
    Next

**Environment:**

-   Name drop-down list proposes a default name for the application.
    (AWSEbWebAppDemo)

-   In the Environment area, in the Name drop-down list, choose
    AWSEbWebAppDemo-dev

-   In the URL box, type a unique subdomain name that will be the URL for your
    web application. (e.g. put your initials after awsebwebappdemo-dev) Choose
    Check Availability to make sure the URL for your web application is not
    already in use. Click Next

**AWS Options:**

-   In Amazon EC2 Launch Configuration, from the Container type dropdown list,
    choose 64bit Windows Server 2016 v1.2.0 running IIS 10.0

-   In the Instance type drop-down list, specify t2.micro as the Amazon EC2
    instance type to use. This will minimize the cost associated with running
    the instance.

-   In the Key pair drop-down list, choose an existing Amazon EC2 instance key
    pair to use to sign in to the instances that will be used for your
    application

![](media/bd5175e30bcd77b28959f9cb408e99b1.png)

In this window, you will also see additional optional configuration options as
follows:

-   **Use non-default VPC**

This option will allow you to deploy application environment in a VPC. The VPC
must have already been created including at least one public and one private
subnet. Elastic Load Balancer for your application will be deployed to public
subnet which is associated with a routing table that has an entry that points to
an internet gateway. Instances created for your application will be placed in
the private subnet.

-   **Single Instance environment**

This option allows you to launch only a single Amazon EC2 instance rather than a
fully load balanced, automatically scaled environment.

-   **Enable rolling deployments**

AWS Elastic Beanstalk provides several options for how deployments are
processed. With rolling deployments, Elastic Beanstalk splits the environment's
EC2 instances into batches and deploys the new version of the application to one
batch at a time, leaving the rest of the instances in the environment running
the old version of the application. During a rolling deployment, some instances
serve requests with the old version of the application, while instances in
completed batches serve other requests with the new version.

For this lab, **uncheck** all three boxes and click Next.

**Permissions:**

-   On the **Permissions** page, accept default values
    **aws-elasticbeanstalk-ec2-role** and **aws-elasticbeanstalk-service-role**.
    **Deployed Application Permissions** will be used to delivery AWS
    credentials to your applications so that it can access AWS resources.
    **Service Permissions** will allow Elastic Beanstalk service to monitor
    environment.

**Application Options:**

-   In the Build and IIS Deployment Settings area, specify target build
    configuration as Release.

-   In App Path box, accept the default path (Default Web Site/) that IIS will
    use to deploy application.

-   In the Health Check URL box, type /api/values. Elastic Beanstalk will use
    this URL to determine if your web application is still responsive.

-   The toolkit will also provide a deployment version label which is based on
    the current date and time. Accept provided label and click Finish.

Click **Deploy**.

Status page for the deployment will open. The deployment may take a few minutes.
When the deployment is complete, you should see Status: “Environment is healthy”
and you can proceed to next step.

![](media/f534bee6394438c47f51786728c67f7f.png)

Testing the Sample Web Application

The toolkit created multiple resources to host your sample .NET core
application. You can navigate left pane to discover those resources such as:

-   EC2 Instances

-   Load Balancer

-   Auto-Scaling Group

Settings for those resources can also be configured using the Toolkit.

![](media/8b8043dc421070c285ed029b6ac8a315.png)

Once the application status is healthy, you can click URL to test your
application.

Add /api/values at the end of the URL. Sample .NET Core Web API application
should return following page:

![](media/b3f249d4383a328e1a04cd157e8d6aa2.png)
