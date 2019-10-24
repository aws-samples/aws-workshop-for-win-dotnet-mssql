**The Migration Life Cycle**




**The Migration Process Workflow**

    * Install the CloudEndure Agent on the Source machine.
    * Start replication if installed with the --no-replication flag.
    * Wait until Initial Sync is finished.
    * Launch a Target machine in Test Mode.
    * Perform acceptance tests on the machine, once the Target machine is tested successfully, delete it.
    * Wait for the Cutover window.
    * Confirm that the Lag is None.
    * Stop all operational services on the Source machine.
    * Launch a Target machine in Cutover Mode.
    * Confirm that the Target machine was launched successfully.
    * Decommission the Source machine.




**Getting started:**
https://aws.amazon.com/cloudendure/getting-started/

Once CloudEndure registration is complete, login through https://console.cloudendure.com (https://console.cloudendure.com/) with your *username (email)* and *password*. 

* 
    * 



    * On the *Create New Project* dialog box, set the following, then click *CREATE PROJECT*.
    * **Project name:** Enter a unique name for the Project. The name can contain up to 255 characters.
    * **Project type:** Select either Disaster Recovery or Migration.
    * **Target cloud:** CloudEndure exclusively utilizes the AWS cloud as a Target infrastructure.
    * **License:** Select a License Package to associate with your Project.



    * You will receive a message stating that your *Project is not set up* until you provide credentials and configure its Replication Settings. Click *CONTINUE* to dismiss the message.



    * To allow CloudEndure to connect to your AWS account for the purpose of replicating your Source machines to an AWS Target infrastructure, you need to generate AWS credentials and enter them into the CloudEndure User Console. These credentials consist of your *Access key ID* and a *Secret access key*.



    * To generate the required AWS credentials to use with the CloudEndure User Console, you need to create at least one AWS Identity and Access Management (IAM) user, and assign the proper permission policy to this user. You will obtain an Access key ID and a Secret access key, which are the credentials you need to enter into the CloudEndure User Console.



    * In the AWS Console, click on *Services *and* then navigate to Security, Identity & Compliance* > *IAM*.



    * On the *Policies* page, click the *Create policy* button.



    * On the Create Policy page, click the *JSON* tab. Navigate to the https://console.cloudendure.com/IAMPolicy.json. 



    * Copy the policy code and paste the copied code into the JSON field. Paste the code over any text that currently exists in the field.



    * Click on *Review policy* at the bottom right of the page.



    * On the Review policy page, enter a name for the new CloudEndure policy in the *Name* field. Enter an optional description in the *Description* field.



    * Click the Create policy button at the bottom right of the page.



    * You will be redirected back to the main Policies page and a confirmation stating that your new policy has been created will appear at the top of the page.



    * After creating an AWS policy which is based on CloudEndure's pre-defined policy, you will need to create a new IAM user and to attach the new policy to this user. You also need to provide this user with a Programmatic access type to enable the use of the new policy. At the end of this procedure, you will be provided with an Access key ID and Secret access key. It is important to save these values in an accessible and secured location, since they are required for running your CloudEndure solution.



    * Navigate to *Users* on the left-hand navigational menu within IAM.



    * Click on *Add user*.



    * On the Add user page, set the following:
    * **User name:** Add a username for the new user.
    * **Access type:** Check the Programmatic access option.



    * Click *Next: Permissions *at the bottom right of the page.



    * On the *Set permissions* page, select the *Attach existing policies directly* option.



    * Locate the policy you created in the previously. You can either search for the policy in the Search box or locate it manually by scrolling through the policy list.



    * Once you have located the policy, check the box next to it.



    * Click the *Next: Tags* button at the bottom right of the page.



    * You do not need to add any tags. Click the *Next: Review* button at the bottom right of the page.



    * On the *Review* page, verify that the correct *User name, AWS access type* (Programmatic access), and *Managed policy* are selected.



    * Click the *Create user* button at the bottom right of the page.



    * A confirmation page will appear. This page provides you with your *Access key ID* and *Secret access key* which you will need to enter into the CloudEndure User Console.



    * Click *Show* under *Secret access key* to see your key.



    * Save your *Access key ID* and *Secret access key*. Then, to finish the procedure, click the *Close* button at the bottom right



    * In the CloudEndure console. Navigate to *Setup & Info* from the main left-hand navigational menu. Within *Setup & Info*, navigate to the *AWS CREDENTIALS* tab.



    * Enter the corresponding credentials that you obtained in the previously into the corresponding fields:
    * **AWS Access Key ID**
    * **AWS Secret Access Key**



    * After you entered your AWS credentials, click the Save button at the bottom right of the page.



    * After entering your AWS credentials in the CloudEndure User Console, navigate to *Setup & Info > REPLICATION SETTINGS.*



    * Next, you will need to define your *Source* and *Target* infrastructures and regions. More information about replication settings can be found here:


https://docs.cloudendure.com/Content/Defining_Your_Replication_Settings/Defining_Replication_Settings_for_AWS/Defining_Replication_Settings_for_AWS.htm


    * Once you have set all of your settings, click the *SAVE REPLICATION SETTINGS* button at the bottom of the page.



    * You will now be able to add machines to your Project. 



    * Click SHOW ME HOW button.



    * The *How To Add Machines* pane will appear. Your Installation Token will be shown in the upper part of the pane under the *Your Agent installation token* header. For more information about installing the agents, please refer to the following link:


https://docs.cloudendure.com/Content/Installing_the_CloudEndure_Agents/Installing_the_Agents/Installing_the_Agents.htm


    * Click the *Download the Windows installer* link at the bottom of the pane under the *For Windows machines* header.



    * Copy or distribute the downloaded *Agent Installer* file to each *Source machine *that you want to include in your solution.



    * Run the *Agent Installer* file on each *Source machine* with your *Installation Token*.



    * After performing these steps, the installation will begin.



    * Once the installation is completed successfully, the replication of the *Source machine* data will start automatically, and you will be able to monitor it through the CloudEndure *User Console*.



    * A Replication Server is launched on the target location which staging disks are attached and data is replicated.



    * Once the initial sync and Data Replication are complete, the *DATA REPLICATION PROGRESS* bar will show *Continuous Data Protection *(Disaster Recovery) or *Continuous Data Replication* (Migration).



    * The *Target machine* Blueprint is a set of instructions on how to launch a *Target machine* for the selected *Source machine*. The Blueprint settings will serve as the base settings for the creation of the *Target machine*.



    * You can access the Machine’s BLUEPRINT by selecting the *BLUEPRINT* tab from the right-hand top navigation menu. For more information about configuring the target machine blueprint, please refer to the following documentation:


https://docs.cloudendure.com/#Configuring_and_Running_Migration/Configuring_the_Target_Machine_Blueprint/Configuring_the_Target_Machine_Blueprint.htm


    * Before you migrate your Source machines into the Target infrastructure, you should test your CloudEndure Migration solution. The *Test Mode* action launches and runs a Target machine in the Target infrastructure for the Source machine you selected for testing.



    * To start the test, click the purple *LAUNCH TARGET MACHINES* button and select the *Test Mode* option.



    * A confirmation message will appear. Click *CONTINUE* to perform the test.



    * Selecting the *Job Progress* menu option opens the *Job Progress* pane. The pane displays detailed information about the progress and status of several actions, including the launch of Test or Recovery machines and the deletion of Target machines.



    * During the machine conversion stage, a conversion instance will be launched temporarily to inject the required AWS binaries to the target machine root volume.



    * You can monitor the job progress until it finishes.



    * You can review the instance ID in the TARGET tab. 



    * Confirm that the Target machine was launched successfully.



    * Perform acceptance tests on the machine.






    * Once the Target machine is tested successfully, you can delete it and launch the Target machine in Cutover Mode.

