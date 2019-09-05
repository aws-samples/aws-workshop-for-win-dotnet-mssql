# Developer - Push sample code and check the pipeline activity

At this stage, although the pipeline is ready but your CodeCommit repository is still empty. Using git client push code to the CodeCommit repo created by the CloudFormation template. Follow the steps [here](https://docs.aws.amazon.com/codecommit/latest/userguide/getting-started.html#getting-started-permissions) to set permissions to push the sample code [here](https://s3-us-west-2.amazonaws.com/vending-pipelines-reinvent/sample-app.zip).

The pipeline has deployed a serverless application that is hosted in AWS CodeCommit in a repository called tasks. Navigate to the repository and notice the template.yaml file on the root. This uses AWS Serverless Application Model (SAM). This SAM template will be deployed through the pipeline and can be found in the AWS CloudFormation console after the pipeline called ‘tasks-pipeline’ has finished execution. Look for a stack called “tasks-test” and in the outputs section copy ApiUrl which will be different than one below
![](images/cfn7.png)

Paste ApiUrl in a browser and append /api/tasks/ at the end. This will provide a list of tasks returned by our API. Our API is now deployed successfully on the ‘test’ stage.


