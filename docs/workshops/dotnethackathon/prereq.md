#### Access to the AWS Console

To login to the AWS Management Console go to [https://console.aws.amazon.com](https://console.aws.amazon.com) and enter the 12 digit account ID that you were given. On the next screen enter the IAM user name and password which were on the same piece of paper as the account ID and then sign-in. 

#### AWS Toolkit for Visual Studio

Before you can use the AWS Toolkit for Visual Studio, you must provide valid AWS credentials. These credentials allow you to access your AWS resources through the AWS Toolkit for Visual Studio. It is considered best practice to use a single-purpose IAM user for this access. 

First create a IAM user called **_visualstudio_** and create AWS Access Keys and assign the Administrator role to the IAM user. You can find more information about this process [here]( https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console)

Once you have created an IAM user follow [these](https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/credentials.html) instructions to configure the AWS Toolkit for access to AWS. If you have properly configured the AWS Toolkit for Visual Studio you should be able to open the AWS Explorer in Visual Studio and navigate to the different resources (e.g. S3, EC2, etc...) and should be able to see the EC2 instance you just created. 