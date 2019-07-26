# Modernize Your First Windows Application with Windows Containers

**Duration: 45 minutes**

### Task 1. Log in to your AWS Account  

Using the console URL and username/password information from the welcome page let's log in to your AWS account.

<br />
### Task 2. Build the Amazon Elastic Container Service (ECS) Cluster

In this task we will build the Windows Server ECS cluster.  

Step 1. In the AWS console change your AWS Region to "EU (Frankfurt)".

[![](/images/1.png)](/images/1.png)

<span style="color:white">a</span>

Step 2. Now let's navigate to the ECS admin interface and then we'll select "Clusters" from the left nav.

[![](/images/2.png)](/images/2.png)

[![](/images/3.png)](/images/3.png)

<span style="color:white">a</span>

Step 3. Click on "Create Cluster" and then select "EC2 Windows + Networking" and then click "Next step"

<span style="color:white">a</span>

Step 4. Enter a Cluster name and then review the configuration options available (we will leave the default values as-is with the exception of the key pair).

!!! info
    Because this is a new AWS account you will need to create a key pair in the Frankfurt Region. Follow the "EC2 Console link" to create a new key pair.

<span style="color:white">a</span>

Step 5. Once the key pair has been created return to the ECS Cluster tab and click the refresh icon next to the Key pair and your new key pair should appear.

[![](/images/4.png)](/images/4.png)

<span style="color:white">a</span>

Step 6. Review the remaining configuration options and click "Create" to build the ECS Windows cluster. While the ECS cluster is building we'll jump over to our dev server and get started with configuring Visual Studio.

<span style="color:white">a</span>



### Task 3. Configure the Dev Server

In this task we will RDP in to our dev server and configure Visual Studio and the AWS Toolkit for Visual Studio. 

Step 7. Let's RDP into your dev server. From the EC2 admin interface click on "Running instances" and then select the "WIN314 Dev Server", click on "Connect", then click on "Download Remote Desktop File" and finally launch the RDP file.

[![](/images/5.png)](/images/5.png)

<span style="color:white">a</span>

Step 8. When you are prompted for credentials first click on "More choices", then click on "Use a different account" and then enter the following credentials:

!!! info
    username:  **.\developer**  

    password:  **ILove.Net!**

[![](/images/6.png)](/images/6.png)

<span style="color:white">a</span>

Step 9. Once we have established an RDP connection to the dev server let's configure the AWS CLI with your AWS account information. Open a command prompt as an administrator (right-click the command prompt, select more and the select Run as administrator) and enter the command: "aws configure", when prompted enter you Access Key and Secret Access Key (included in the email sent by your instructor). 

[![](/images/7.png)](/images/7.png)

<span style="color:white">a</span>

Step 10. Now let's open Visual Studio (VS) 2017 Community edition and configure the AWS Toolkit for Visual Studio with your AWS account information. Launch Visual Studio and wait a few seconds for the AWS Explorer UI to appear. If it doesn't appear from the VS menu select View -> AWS Explorer and enter your AWS account information if prompted. From the AWS Explorer let's change the AWS Region to Frankfurt.

[![](/images/8.png)](/images/8.png)

!!! tip
    Once you change the Region you can expand the ECS item and double-click your ECS cluster to see it's current status  

[![](/images/9.png)](/images/9.png)

<span style="color:white">a</span>

Step 11. Now let's open our sample .NET application. From the Start Page tab (or form the Visual Studio menu File -> Open -> Project/Solution) open the "MvsMusicStore-Wed-F2017" Solution (located at C:\Source)

<span style="color:white">a</span>

Step 12. Once the solution has loaded let's run it locally to make sure the application is working. You may receive some warnings regarding SSL, self-signed certificates, the current debug mode, etc. Simply accept those warnings and then the application should render:

[![](/images/10.png)](/images/10.png)

<span style="color:white">a</span>

Now that have confirmed we have a running application let's start the process of containerizing our application.

<span style="color:white">a</span>



### Task 4. Containerize .NET App in Visual Studio

In this task we will containerize the application in Visual Studio using Docker compose. 

Step 13. Let's start by adding Docker support to our project. Right-click the project and select Add -> Container Orchestrator Support. Leave the default value for "Docker Compose" and click OK.

[![](/images/11.png)](/images/11.png)

<span style="color:white">a</span>

Step 14. Visual Studio has now added Docker Compose support to our project and a Docker file. If you read through the Output window you will notice that docker has also started a container and is running the application inside that container locally on the dev server.

[![](/images/12.png)](/images/12.png)

<span style="color:white">a</span>

Step 15. Let's take a quick look at the docker container that is running locally and let's also browse to the application that's running inside the container to verify that it's working as expected. Open a Command Prompt as an administrator and enter the following docker command: "docker ps"

The docker ps command lists the running Docker processes or containers. We should see that one container is running on the dev server. Now let's take a closer look at this container by entering the following command: docker inspect '<CONTAINER ID>.

!!!tip
    You only need to enter enough of the CONTAINER ID value for docker to be able to uniquely identify the container. In my case the commands looked like this:

[![](/images/13.png)](/images/13.png)


<span style="color:white">a</span>

Step 16. Near the bottom of the output form the docker inspect command will list the IP address of the container. Let's grab the IP address, open a browser and verify the application is running correctly from within the docker container. 

[![](/images/14.png)](/images/14.png)

<span style="color:white">a</span>

Congratulations you have containerized a .NET application using Visual Studio and Docker. In the next task we will push the container (containing our application) to your Elastic Container Registry (ECR) on AWS.

<span style="color:white">a</span>




### Task 5. Push the Container to ECR

In this task we will push the container from Visual Studio to ECR. 

Step 17. Let's start by opening the docker-compose.yml file and copy the image name.

[![](/images/15.png)](/images/15.png)

<span style="color:white">a</span>

Step 18. Next let's create a new ECR repository. From the AWS Explorer menu expand the Amazon Elastic Container Service section and right-click Repositories and click on Create Repository... 

[![](/images/16.png)](/images/16.png)

<span style="color:white">a</span>

Step 19. Enter the Docker compose image name from step #17 above and click OK. 

[![](/images/17.png)](/images/17.png)

<span style="color:white">a</span>

Step 20. Once the new repository has been created you can expand the Repository section in the AWS Explorer and double-click on the new repository. You can see the repository metadata and that the repository is currently empty. Click on the "View Push Commands" link to see a list of helpful PowerShell and AWS CLI commands for interacting with this repository. Click on the "AWS CLI" tab.

[![](/images/18.png)](/images/18.png)

<span style="color:white">a</span>

Step 21. From the AWS CLI tab copy the first command (1. Retrieve the docker login command that you can use to authenticate your Docker client to your registry). We will use the output of this command to allow Visual Studio to authenticate and push the container to our repository. 

[![](/images/19.png)](/images/19.png)

<span style="color:white">a</span>

Step 22. Copy the command from the previous step and run the command as an administrator. The output contains three values: -u for username, -p for password, and the URL of the repository. Leave this command prompt open and we'll copy these values to use in the next step. 

[![](/images/20.png)](/images/20.png)

<span style="color:white">a</span>

Step 23. Now let's configure the publish action on the project. We are going to configure a publish action to a custom container registry. Right-click the project and select Publish. 

[![](/images/21.png)](/images/21.png)

<span style="color:white">a</span>

Step 24. Select "New Profile...", then select "Container Registry", then "Custom" and click Publish. Now we can copy/paste the values from the previous command prompt window in to the Visual Studio Publish UI. 

[![](/images/22.png)](/images/22.png)

<span style="color:white">a</span>

Step 25. Once the values are entered and you click publish Visual Studio will begin to publish the container to your ECR repository on AWS. A Docker prompt will appear to indicate progress of the publish action. 

[![](/images/23.png)](/images/23.png)

<span style="color:white">a</span>

Step 26. Once the publish action is complete you can go back and refresh the repository view from the AWS Explorer and you should see that your repository now has one container image. 

[![](/images/24.png)](/images/24.png)

<span style="color:white">a</span>

Congratulations you now have a container image in AWS that you can deploy to your ECS environment. In the next task we will deploy your container as a task within ECS. 




### Task 6. Deploy and Run the Container on ECS

In this task we will create an ECS Task to run the container that has been pushed to ECR.

Step 27. Let's jump back to your AWS console and navigate to the ECS admin interface. Once there let's verify again that our container image is in the repository. From the ECS interface under Amazon ECR select Repositories and then click on the repository that we created previously. You should see the container image that we created and pushed.

!!!tip
    Make a note of Repository URI and the image tag. We will use those values in a future step to identify the container image.   

[![](/images/25.png)](/images/25.png)

<span style="color:white">a</span>

Step 28. Now let's create a Task Definition. Select Task Definitions from the left nav and click on Create a new Task Definition. Select EC2 and click next.

[![](/images/255.png)](/images/255.png)

<span style="color:white">a</span>

Step 29.

 Enter a name for the task, review the configuration options available (we'll leave the default values as-is) and then scroll down and click on "Add container".  

[![](/images/26.png)](/images/26.png)

[![](/images/27.png)](/images/27.png)

<span style="color:white">a</span>

Step 30. In the "Add container" UI let's enter a Container name, and in the image field we'll use the values from our repository noted in step #TBD. Pay close attention to the format required here: repository-url/image:tag  

!!!info
    In my example the value for the Image field would be: 353497669637.dkr.ecr.ca-central-1.amazonaws.com/mvcmusicstorewedf2017:latest

Let's enter 1024 (1GB) for a Memory Limit, and for Port mappings let's enter 8080 for the Host port and 80 for the Container port. So far your form should look like the following:

[![](/images/28.png)](/images/28.png)

<span style="color:white">a</span>


Let's scroll down and enter 1024 for "CPU units" and enter the following value for "Entry point": C:\ServiceMonitor.exe, w3svc and then click Add

[![](/images/29.png)](/images/29.png)

<span style="color:white">a</span>

Step 31. You should now see your container under Container Definitions in the Task Definitions form, click on Create and you should see the "Created Task Definition Successfully" message. 

[![](/images/30.png)](/images/30.png)

[![](/images/305.png)](/images/305.png)

<span style="color:white">a</span>

Step 32. The final step in the sequence is to run the task we just created on our ECS host. From the Task Definitions interface mark/select the Task Definition that we just created and click on the Actions button and select Run Task. 

[![](/images/31.png)](/images/31.png)

<span style="color:white">a</span>

Step 33. Select a launch type of EC2, enter a Task Group name and then click on Run Task.

[![](/images/32.png)](/images/32.png)

<span style="color:white">a</span>

Step 34. You should receive a "Created tasks successfully" message and now let's refresh the ECS Cluster UI until we see that our task status is no longer PENDING and has turned to RUNNING. 

[![](/images/33.png)](/images/33.png)

<span style="color:white">a</span>

Step 35. At this point our container (and application) have been successfully deployed to our ECS Cluster. Now let's test the application to make sure it's running correctly. We'll first test the application locally from the ECS host server and then we'll test the application from the Internet.

To do that we'll first need to modify the Security Group rules to allow us to RDP into our ECS host server. Click on the link for "Container" and then click on the EC2 Instance ID.

[![](/images/34.png)](/images/34.png)

[![](/images/35.png)](/images/35.png)

<span style="color:white">a</span>

Step 36. From the EC2 admin interface note down the public IP address for use later and then under "Security groups" click on the one security group link.

[![](/images/36.png)](/images/36.png)

<span style="color:white">a</span>

Step 37. First select the "Inbound" tab, then select "Edit", then select "Add Rule", then select "RDP from the dropdown, then enter "0.0.0.0/0" for the CIDR and finally click Save.

[![](/images/37.png)](/images/37.png)

<span style="color:white">a</span>

Step 38. Let's RDP into our ECS Host and run a docker ps command to verify that our task/container is running.

[![](/images/38.png)](/images/38.png)

<span style="color:white">a</span>

Step 39. Now lets run a dicker inspect command on our running container and grab it's IP address.

[![](/images/39.png)](/images/39.png)

<span style="color:white">a</span>

Step 40. And using the container's IP let's browse the site locally.

[![](/images/40.png)](/images/40.png)

<span style="color:white">a</span>

Step 41. We've now confirmed that our ECS task/container is running correctly on our ECS host. The final step will be to browse to the site from the Internet using port 8080 per the task port mapping we created earlier. From your laptop open a browser and using the public IP address of the ECS host recorded in step #36 append port 8080 to the IP address and browse to the site.