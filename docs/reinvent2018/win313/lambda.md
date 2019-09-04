# Deploy AWS Lambda with Azure DevOps (VSTS)

## Introduction

> In this lab, you will learn how to use Azure DevOps and AWS VSTS tool to deploy AWS Lambda project.  

## Prerequisites

1. Complete the [Lab Setup](setup.md).
2. Create an **IAM User** using the AWS Management Console, as [described here.](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console)
3. Create an **Access Key** for the IAM User by following  [these instructions](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey).
4. You will need the **AWS CLI** installed and configured. If you don't already have it you can follow [these instructions](https://docs.aws.amazon.com/lambda/latest/dg/setup-awscli.html).
5. You will need **Git** installed locally. If not, you can install as [described here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
6. You will need the **.NET Core CLI** installed. If not, install as described in   [these instructions](https://www.microsoft.com/net/download).

## Create an IAM Role for your Lambda Function

> In this section we will create an IAM Role in your AWS Account for the Lambda Function. This is the permission that the lambda function can do when it assumes this role. Learn more about Lambda role [here.](https://docs.aws.amazon.com/lambda/latest/dg/intro-permission-model.html#lambda-intro-execution-role)

<ol>
  <li><a href="https://console.aws.amazon.com/">Log in</a> to your AWS Account and go to IAM Console.</li>
  <li>Go to <b>Role</b> and click <b>Create Role</b>. Select <i>AWS Service</i> for Type of trusted entity then slect <i>Lambda</i> as the service that will use this role. Click <b>Next: Permission</b></li>
  <li>Filter and Select <i>AWSLambdaBasicExecutionRole</i> and click <b>Next: Tags</b></li>
  <li>Click <b>Next: Review</b> and name the Role. Review the configuration and click <b>Create Role</b></li>
</ol>

![alt text](images/lambda/vsts29.png "Lambda Role")

## Create Azure DevOps project

> In this section we will create an Azure DevOps project and clone the repo to your local working environment.

<ol start="1">
<li><a href="https://app.vssps.visualstudio.com">Log in</a> to your Azure DevOps account and create a project. It takes some time to complete.</li>
</ol>

<img src="images/lambda/vsts1.png"> 

<ol start="2">
<li>Create a Personal Access Token.</li>
  <ol start="a">
      <li>Click on <b>your avatar</b> in the top-right of the screen and then click <b>Security</b>.</li>
      <li>Under the Personal Access Tokens section, click <b>New Token</b>.</li>
      <li>Enter a value in the Name field, select <i>Full Access</i> under Scope, and click <b>Create.</b></li>
      <li>Copy <i>the token</i> to a temporary storage location and click <b>Close</b>.</li>
  </ol>
<li>Create AWS service connection for this project.</li>
    <ol start="a">
      <li>On your Summary page on the project, click <b>Project settings</b> on the bottom left menu bar</li>
      <li>Click <b>Service connection</b> under Pipelines then click <b>+</b> New service connection.</li>
      <li>Enter <i>Access Key ID</i> and <i>Secret Access Key</i> of your IAM user.</li>
    </ol>
</ol>

![alt text](images/lambda/vsts21.png "VSTS Project")

![alt text](images/lambda/vsts22.png "VSTS Project")

For more information see this [instruction](https://docs.aws.amazon.com/vsts/latest/userguide/getting-started.html#set-up-aws-credentials-for-the-aws-tools-for-vsts) to Add AWS service connection for this project.

<ol start="4">
<li>Click in the project and select Repos. Copy Git repo address.</li>
</ol>

![alt text](images/lambda/vsts2.png "Git Repo")

Select *Add ReadMe file* and add *gitignore* for VisualStudio.  Click *Initialize*.

On you command line type the command below to clone your newly created code repository to your local machine. Enter your Azure DevOps username and use your Personal Access Token as the password. use git repo you copied in step 4 in the git clone command.

```powershell
git clone https://{git repo account}@dev.azure.com/{git repo account}/ReInventLambda/_git/ReInventLambda
```

## Create a simple Lambda project

> In this session, we will create a simple dotnet Lambda project using donet CLI and push it to Azure DevOps git repository.

<ol start="1">
<li>Install AWS Lambda template.</li>
</ol>

```console
dotnet new -i Amazon.Lambda.Templates
```

Once the install is complete, verify if the Lambda templates are listed.

```console
dotnet new -all
```

![alt text](images/lambda/vsts3.png "Dotnet new")

<ol start="2">
<li>Create a new Lambda project. Name function name <b>ReInventLambda</b>, choose your AWS profile and AWS region.</li>
</ol>

```console
dotnet new lambda.EmptyFunction --name ReInventLambda --profile default --region us-west-2
```

<ol start="4">
<li>Browse into the folder. Examine the folder structure.</li>
</ol>

```console
cd ReInventLambda
```

<ol start="3">
<li>Use your favorite text editor to open ..\ReInventLambda\src\ReInventLambda\aws-lambda-tools-defaults.json and resave it as UTF-8 (with no BOM) encoding. In this example, we use Visual Studio Code.</li>
</ol>

![alt text](images/lambda/vsts30.png "VS Code")

<ol start="4">
<li>Commit the new code to local and remote (Azure DevOps) repository.</li>
</ol>

```
git add *
git commit -m "Lambda empty function first commit"
git push
```

<ol start="4">
<li>In Azure DevOps, examine your repo.</li>
</ol>

## Create Build pipeline

> In this section, we will configure Build Pipeline using AWS Lambda.NET Core Deployment task. We will output the artifact to Azure DevOps.

<ol start="1">
<li>Select <b>Pipelines, Builds</b>, hit <b>+</b> button and select <b>New build pipeline</b>.</li>
<li>Click Use the <b>visual designer</b>.</li>
<li>Select <b>Source, Team project, Repository and branch</b>. Click <b>Continue</b>.</li>
  <ul>
    <li><b>Select a source: </b>Azure Repos Git</li>  
    <li><b>Team project: </b>ReInventLambda</li>
    <li><b>Repository: </b>ReInventLambda</li>
    <li><b>Default branch for manual and scheduled builds: </b>master</li>
  </ul>
<li>Select start with an Empty job by clicking <b>Empty job</b>.</li>  
</ol>

![img](images/lambda/vsts11.png)

<ol start="5">
<li>Under Tasks, Pipeline, name the Build pipeline and select <b>Hosted VS2017</b> as Agent pool.</li>  
<li>Under Agent job 1, name Agent job and select <b>inherit from pipeline</b> for Agent pool.</li>
<li>Click <b>+</b> button at Agent job 1 task, to Add a task. In the search box, enter <i>PowerShell</i>. Add <b>PowerShell Task</b>.</li>
<ul>
    <li><b>Display name: </b>Install Amazon.Lambda.Tools</li>
    <li><b>Type: </b>Inline</li>
    <li><b>Scripts: </b>Enter the script bellowed.</li>
</ul>
</ol>

```
Write-Host 'Installing .NET Global Tool Amazon.Lambda.Tools'
Write-Host "dotnet tool install Amazon.Lambda.Tools --tool-path C:\Program Files\dotnet\tools"


# Using stream redirection to force hide all output from the dotnet cli call
& dotnet tool install Amazon.Lambda.Tools --tool-path "C:\Program Files\dotnet\tools" *>&1 | Out-Null

if ($LASTEXITCODE -ne 0)
{
        Write-Verbose -Message 'Error installing, attempting to update Amazon.Lambda.Tools'

        # When "-Verbose" switch was used this output was not hidden.
        # Using stream redirection to force hide all output from the dotnet cli call
        & dotnet tool update Amazon.Lambda.Tools --tool-path "C:\Program Files\dotnet\tools" *>&1 | Out-Null

if ($LASTEXITCODE -ne 0)
{
            $msg = @"
Error configuring .NET CLI AWS Lambda deployment tools: $LastExitCode
CALLSTACK:$(Get-PSCallStack | Out-String)
"@
            throw $msg
}
}

Write-Host "Confirm if the tool is intalled"

get-childitem "C:\Program Files\dotnet\tools"

Write-Host "Add path to AWS tool to env variable."

$env:Path += ";C:\Program Files\dotnet\tools"

Write-Host "PATH variable is "
$env:Path

Write-Host "##vso[task.setvariable variable=PATH;]${env:PATH};$env:Path";
```

![img](images/lambda/vsts28.png)

This task is necessary if you are using the new .NET Core Global tool (.NET Core SDK 2.1.300 and later versions). With this change, the csproj file no longer include DotNetCliToolReference (see below). That means dotnet restore will not automatically download the tool during the build time. This task downloads and saves the tool in the specified location. The tool will be referenced in the next step.

```
<ItemGroup>
   <DotNetCliToolReference Include="Amazon.Lambda.Tools" Version="2.2.0" />
</ItemGroup>
```

<ol start="8">
<li>Click <b>+</b> button at Agent job 1 task to add a task. In the search box, enter <i>aws</i>. This should filter only AWS related tasks. Select <b>AWS Lambda.NET Core Deployment</b> then click <b>Add</b>.</li>
</ol>

<ol start="9">
<li>Configure Deploy.NET Core to Lambda task.</li>
  <ul>
    <li><b>Display name: </b>Deploy .NET Core to Lambda</li>
    <li><b>AWS Credentials: </b>AWS Note: AWS Credential was created in prerequisites section.</li>
    <li><b>Region: </b>Select AWS Region where you wanted your Lambda function to reside.</li>
    <li><b>Deployment Type: </b>Function</li>
    <li>Check <b>Create deployment package only</b></li>
    <li><b>Package-only output file: </b>$(Build.ArtifactStagingDirectory)\ReInventLambda.zip</li>
    <li><b>Path to Lambda Project: </b>browse to the directory containing the Lambda Project file</li>
  </ul>
</ol>

Do not need to fill Lambda Function Properties, Advanced, Control Options and Output Variables.  

![img](images/lambda/vsts27.png)

<ol start="10">
<li>Click <b>+</b> to add a task. Select <b>Publish build Artifacts</b> and click <b>Add</b>. Configure task as seen below.</li>
  <ul>
    <li><b>Display name: </b>Publish Artifact: PackagedLambdaFunction</li>
    <li><b>Path to publish: </b>$(Build.ArtifactStagingDirectory)\ReInventLambda.zip Note: this is Package-only output file from the previous step</li>
    <li><b>Artifacts name: </b>PackagedLambdaFunction</li>
    <li><b>Artifact publish location: </b>Azure Pipelines/TFS</li>
  </ul>  
</ol>

![img](images/lambda/vsts26.png)

Select **Save & queue**.

<ol start="11">
<li>Examine Build logs.
</ol>

![img](images/lambda/vsts25.png)

<ol start="12">
<li>If you face this error, use your favorite text editor to re-save aws-lambda-tools-defaults.json with UTF-8 with no BOM file encoding.</li>
</ol>

![img](images/lambda/vsts24.png)

## Create Release pipeline
> In this section, we will use AWS Lambda Deploy Function task to deploy the output build artifact from the last section to AWS Lambda function.

<ol start="1">
<li>Select <b>Pipelines, Releases and New Release pipeline</b>. In the New release pipeline, select <b>start with an Empty job</b>.</li>
<li>To add the artifact to the release pipeline, click <b>Add an Artifact</b> and configure as followed:</li>
  <ul>
    <li><b>Source type: </b>Build</li>
    <li><b>Project: </b>ReinventLambda</li>
    <li><b>Source (Build Pipeline): </b>ReinventLambda-CI</li>
    <li><b>Default version: </b>Latest</li>
    <li><b>Source alias: </b>_ReinventLambda-CI</li>
  </ul>  
</ol>

Click **Add**.  

![img](images/lambda/vsts15.png)

<ol start="3">
<li>Click <b>Stage</b> and name the stage.</li>
<li>Click <b>1 job, 0 task</b> to view task. </li>
<li>At Agent job, click <b>+</b> to add a task. In the search box, type AWS. Select AWS Lambda Deploy Function and click Add.</li>
</ol>

![img](images/lambda/vsts16.png)

<ol start="6">
<li>Configure Deploy Lambda Function task.</li>
  <ul>
    <li><b>Display name: </b>Deploy Lambda Function: ReInventLambda</li>
    <li><b>AWS Credentails: </b>AWS Note: AWS Credential was created in prerequisites section.</li>
    <li><b>Region: </b>Select the same AWS Region as in the previous step.</li>
    <li><b>Deployment Mode: </b>Update code and configuration (or create a new funtion).</li>
    <li><b>Function name: </b>ReInventLambda</li>
    <li><b>Function Handler: </b>ReInventLambda::ReInventLambda.Function::FunctionHandler</li>
    <li><b>Runtime: </b>dotnetcore2.1</li>
    <li><b>Code Location: </b>Zip file in the work area</li>
    <li><b>Zip File Path: </b>$(System.DefaultWorkingDirectory)/_ReInventLambda-CI/PackagedLambdaFunction/ReInventLambda.zip </li>
    <li><b>Role ARN or Name: </b>Lambda-ServiceRole-BasicExecution  Note: This is the Lambda service role created in Prerquisite section.</li>
    <li><b>Memory Size: </b>256</li>
    <li><b>Timeout: </b>30</li>
    <li>Check <b>Publish </b></li>
  </ul>  
</ol>  

Leave everything else as default in other sections. Click **Save** (at the top) to save the pipeline.

![img](images/lambda/vsts17.png)

<ol start="7">
<li>At the top, click <b>Release</b> and select <b>Create a release</b>. Review the release and click <b>Create</b>.</li>
<li>Select the release to view its status.</li>
</ol>

![img](images/lambda/vsts19.png)

<ol start="9">
<li>Log in to AWS Lambda console to view the Function.</li>
</ol>

## Testing the function using .net CLI

> In this section, we will use dotnet CLI to test our newly created Lambda Funtion

Install dotnet Lambda Tools and test the function.

```console
dotnet tool install -g Amazon.Lambda.Tools
dotnet lambda invoke-function ReInventLambda --payload "Just checking"
```

![img](images/lambda/vsts20.png)
