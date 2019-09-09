AWS Systems Manager Hands on Lab Guide
======================================

Overview
--------

This hands-on lab is designed to get you familiar with the concepts and the
process of using AWS Systems Manager. In the lab we provide “High Level
Directions”. These are the steps you should use as the guidelines of what you
need to build out. We encourage you to play around and test the steps in various
ways. If you have a question about how something works, feel free to both ask a
proctor and test it by trying various things. Feel free to play around! 😊

This design was built off of feedback received from running other customer labs
and we are very interested in getting your feedback at the end of the event
today on your experience with this lab format.

**High Level Directions**
-------------------------

### Grab the directions and supporting files

>   The zip file will have all of the reference files we will use in the lab
>   today. The files are also linked individually in this document. The
>   PowerPoint deck from today will also be in the zip file.

-   *Download the file ssm-lab.zip and extract the* contents  
    <https://s3.amazonaws.com/ssmdocs/ssmlab/ssm-lab.zip>

### Setup base infrastructure

>   In this first step, you setup EC2 Instances that you will manage with AWS
>   Systems Manager. The instances need to have the ability to read from the AWS
>   range of IP addresses for the region and have the IAM role assigned. Both
>   are required for the instances to list under managed instances.

-   Login into your AWS account

-   Create an IAM role for instance to view ssm documents  
    <https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-access.html>

-   Make sure the instances have the ssm role assigned that you created above

-   Create 3 Windows 2016 servers. (TAG Platform=Windows) (Use free tier
    T2Micro)  
    Create 3 Amazon Linux servers. (TAG Platform=Linux) (Use free tier T2Micro)

![](media/97c529a12477842d5a57589b59852058.png)

Add another tag to all 6 instances (TAG Type=Webserver)

-   Open Port 80 & 443 as these servers will be webservers

### Run Command

>   Run command is the first service offered and is the base of the management
>   services in EC2 Systems manager. For details steps you can refer to the docs
>   here:  
>   <http://docs.aws.amazon.com/systems-manager/latest/userguide/rc-console.html>

-   Update the ssm agents on the 6 instances using Run Command  
    Make sure your instances show under the Managed Instances tab

-   Using run command install the IIS webserver role on the Windows Servers  
    and install the sample website  
    <https://s3.amazonaws.com/ssmdocs/ssmlab/Install-iis-and-website.ps1>  
    Use the aws-runpowershell SSM Document

-   Using run command install Nginix webserver on Linux  
    and install the sample website  
    <https://s3.amazonaws.com/ssmdocs/ssmlab/install-nginx.sh>  
    Use the aws-runshellscript SSM Document

-   Now browse to the ipaddress of the servers and view site

### State Manager

>   Improve the security profile of your servers by disabling SSH and RDP access
>   to them. Using State Manager, you can continually have your configuration
>   re-apply. So, in our example, if someone enables remote access to the server
>   – it will automatically be removed when State Manager runs again. Detailed
>   steps on State Manager are here:
>   <http://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-state-walk.html>

-   *Remote into a Windows and Linux server*

-   *Create a* new document that turns off both SSH and RDP  
    Use this document
    <https://s3.amazonaws.com/ssmdocs/ssmlab/ssh-rdp-disable-doc.txt>  
      
    A guide to creating documents can be found here:  
    <http://docs.aws.amazon.com/systems-manager/latest/userguide/create-ssm-doc.html>

-   Create a State Manager Association of that document to all instances  
    Have it run once a day

-   See if it is running – hit “apply association now” button if not

-   Read the results in the Output tab

-   See if the remote access sessions have been closed.

-   Compare the document to the PowerShell and Shell script to re-enable remote
    access  
    <https://s3.amazonaws.com/ssmdocs/ssmlab/enableRDP.ps1>  
    <https://s3.amazonaws.com/ssmdocs/ssmlab/start-ssh.sh>

-   Turn back on remote access with Run Command if you wish

### Patch Manager

>   Getting control of patching is one of the top interests’ customers have in
>   AWS Systems Manager. Patch Manager is an automation tool that helps you
>   simplify your patching process. There are several SSM documents around
>   patching. We will use the AWS-RunPatchBaseline SSM document to configure
>   patching and compliance.

>   Step by step directions can be found here:
>   <http://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-patch-walkthrough.html>

-   Create a Patch Baseline for Windows Server 2012R2 and 2016  
    Have all critical updates install with a 1-day delay  
    Have all security updates install with a 7-day delay  
    Set compliance level to “High”

-   Create a Patch Baseline for Amazon Linux  
    Have security patches install after a 7-day delay  
    Set compliance level to “High”

-   Set these Patch Baselines to be the default

### Maintenance Window

>   This section of the lab will continue with the Patch Manger section above.
>   Please continue following the same walkthrough used above:
>   <http://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-patch-walkthrough.html>

-   Create a role and name it SSMMaintenanceWindowRole  
    <https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-maintenance-perm-console.html>  
    This role will be used by the Maintenance Windows to run

-   Create a patching maintenance windows  
    Have it run Sunday at 01:00 UTC for 8 hours

-   Register Targets to the patching maintenance windows by using tags  
    (Tag Type=Webserver)

-   Register Run Command Task – on that maintenance window  
    Choose the document AWS Run Patch Baseline

    Congratulations you finished your patching, compliance, and maintenance
    window work. You will need to wait until the maintenance window to see if it
    worked.

### Setup Inventory to run weekly

### The inventory service enables you to capture information about your servers from installed software and patches to a custom option in which you can get any information on or about your server. There are step by step directions here: http://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-inventory-configuring.html

-   From the Managed Instances tab – select “Setup Inventory”

-   Target instance with Tag Type=Webserver

-   Schedule to run every 12 hours

-   Enable all type of information (do you know what each gathers?)

-   (optional) Add an S3 Bucket to collect all inventory – You can use
    QuickSight to build visualizations

### AWS config

>   AWS Config is a service that enables you to assess, audit, and evaluate the
>   configurations of your AWS resources. Config continuously monitors and
>   records your AWS resource configurations and allows you to automate the
>   evaluation of recorded configurations against desired configurations. With
>   Config, you can record and review historical changes in your inventory that
>   EC2 Systems Manager records. This enables you to determine your overall
>   compliance against the configurations specified in your internal guidelines.
>   This enables you to simplify compliance auditing, security analysis, change
>   management, and operational troubleshooting.

![](media/100f093110d5ec9bad9155d5b715631b.png)

-   *Turn on AWS Config on to record just your EC2 Systems Manager inventory
    information or turn it on to recording* everything that happens in your
    account and this will include inventory.

-   Click - Managed Instance – Actions – Edit AWS Config recording

-   Turn on either ManagedInstanceInventory or Record All (It is recommended to
    record everything)

Make sure your Inventory ran and then go look at what has populated in the
inventory of each machine. Look at the insights page to see what the top
applications are or what the top 5 operating systems are.

### Parameter Store

>   The Parameter Store is a useful tool to store passwords and other important
>   data that are used in your server management. It adds improves both security
>   and the ease of updating the parameter information.

-   Create a parameter for the Windows administrator password  
    Label it “AdminPass” – and make it complicated enough for Windows policy

-   Use run command to update all the Windows machines with the new password  
    Hint: Target the machines with the TAGs feature  
    <https://s3.amazonaws.com/ssmdocs/ssmlab/UpdateWindowsAdminPassword.ps1>

### Extra Credit

>   This extra credit section is for those who work faster than the rest and
>   have the time to build out more. We will simulate adding an on-prem Linux
>   box by adding a server from a different region. Documented steps:
>   <http://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-managedinstances.html>

-   Create an Ubuntu server in a different region

-   SSH into the server

-   Install the SSM agent on the server

-   Create Activation – copy both strings (Activation Code & ID)

-   Connect it as a remote server – using this script

-   <https://s3.amazonaws.com/ssmdocs/ssmlab/UbuntuInstallSSMagent.sh>  
    Update the script with the Activation Code, ID, & Region  
    sudo amazon-ssm-agent -register -code "code" -id "id" -region "region"

-   Install the webserver with a Run Command as we did above  
    Note Ubuntu uses apt-get instead of yum

Awesome – you finished the labs - Important
-------------------------------------------

When you are done with the lab you may want to delete the resources you created
to avoid getting charged for the services you have created. If you used the free
tier instance – they can run for the first year of your account without a charge
but after 1 year they will start to bill.

Appendix
========

You can get some more details on Systems Manager here:  
<http://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-setting-up.html>  
<https://github.com/awsdocs/aws-systems-manager-user-guide>
