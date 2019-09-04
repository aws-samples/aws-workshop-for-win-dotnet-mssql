#### Summary

Acme Inc. has decided to fund a small team that have been tasked with creating a disruptive product for the company. In true startup fashion the company has placed several constraints on the team including limited funding and personnel, as such the team has decided to use a serverless architecture. The goal of this challenge is to create a serverless application using .NET Core and the Serverless Application Model.

#### Suggested Technology

* [Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)

* [API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)

* [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)

* [Serverless Application Model](https://docs.aws.amazon.com/lambda/latest/dg/serverless_app.html)

#### Sample .NET Serverless Application

* [Serverless .NET Core Application Project](https://s3.amazonaws.com/musiquizza/Musiquizza-React.zip)

* [Live Demo of Sample .NET Serverless Application](https://w0ez5wni2e.execute-api.us-east-1.amazonaws.com/Prod)

#### Notes about the application

* Front end is in React using React Router

* Table with Songs was created in DynamoDb and can easily be replicated

* Your serverless app doesn't have to use DynamoDb in the backend but the assembly in the above app can be easily be used as it is generic if you choose to do so.

#### Goal

The goal of this challenge is to take the existing .NET Core serverless application and deploy it to AWS using the Serverles Application Model (SAM). Visual Studio is capable of deploying Serverless applications to AWS.


