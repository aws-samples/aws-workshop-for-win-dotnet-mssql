#### Summary

Acme Inc. has a number of legacy applications that are tightly coupled and these dependencies led to long times between updates (measured in months) and require weeks of testing to ensure changes in one application don't break changes in a different application. The applications themselves are not suited for a micro-service architecture at this point in time but your manager would like your team to decouple the applications using AWS messaging services.

#### Suggested Technology

* [EC2](https://docs.aws.amazon.com/en_us/AWSEC2/latest/UserGuide/ec2-ug.pdf) 

* [SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html)

* [SNS](https://aws.amazon.com/documentation/sns/)

___   

#### Amazon Simple Queue Service (SQS)

Amazon SQS is a fast, reliable, scalable, fully managed message queuing service. Amazon SQS makes it simple and cost-effective to decouple the components of a cloud application. You can use Amazon SQS to transmit up to 2 GB of data, at any level of throughput, without losing messages or requiring other services to be always available. With Amazon SQS, you can offload the administrative burden of operating and scaling a highly available messaging cluster, while paying a low price for only what you use.

#### Amazon Simple Notification Service (SNS)

Amazon SNS provides significant advantages over the complexity of developing custom messaging solutions or the expense of licensed software for systems that need to be managed and maintained on site. It runs within Amazon's proven network infrastructure and data centers, so topics will be available whenever applications need them. To prevent messages from being lost, all messages published to Amazon SNS are stored redundantly across multiple servers and data centers. It allows applications and end users on different devices to receive notifications via mobile push notification (Apple, Google and Kindle Fire Devices), HTTP/HTTPS, Email/Email-JSON, SMS or Amazon SQS queues, or AWS Lambda functions. One common design pattern is called â€œfanout.â€ In this pattern, a message published to an SNS topic is distributed to several SQS queues in parallel. This allows you to build applications that take advantage of parallel, asynchronous processing.

---

![Lab 5 Diagram](http://us-west-2-tcdev.s3.amazonaws.com/courses/AWS-100-DEV/v2.3/lab-5-sqs-sns/scripts/lab-5-diagram.png)

#### Overview

Acme Inc. has a e-commerce application that sends email to it's customers after they have placed an order. The emails are sent from the e-commerce application but the email module for the e-commerce platform is unreliable and a black box. Acme Inc. would like to turn off the email module and leverage AWS to send emails. You need to build a proof of concept that will leverage Amazon SQS (message queue) and Amazon SNS (pub/sub messaging).

The application requirements are as follows: 

1) Send emails to customers (subscribers) about their orders

2) Send order messages to multiple SQS queues so those messages can be processed by other applications. 

3) Receive and process messages from an SQS queue


#### Set Up SNS Topics and SQS Queues

In this section, you will set up the following SNS topics and SQS queues required for your application:

- `EmailSNSTopic`: SNS topic to send email notifications.
- `OrderSNSTopic`: SNS topic to send order messages to subscribers.
- `MySQSQueue_A`: SQS queue processed by SQSConsumer class.
- `MySQSQueue_B`: SQS queue processed by some other application.

You will setup the SQS queues (`MySQSQueue_A` and `MySQSQueue_B`) as subscribers to `OrderSNSTopic`.

For instructions on creating SNS Topics click [here](https://docs.aws.amazon.com/sns/latest/dg/CreateTopic.html) and SQS Queues click [here](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-create-queue.html)


#### Develop SNS Publisher

In this section, you will develop an application that publishes messages to SNS topics.

Your application will send email messages to the `EmailSNSTopic` topic and order messages to the `OrderSNSTopic` topic.


For information about using the SDK, see [Using the AWS SDK for .NET with Amazon SNS](http://docs.aws.amazon.com/AWSSdkDocsNET/latest/V3/DeveloperGuide/sns-apis-intro.html).

The order messages published to the `OrderSNSTopic` were successfully sent to `MySQSQueue_A` and `MySQSQueue_B`.

- `MySQSQueue_A` contains raw messages without the JSON wrapper attributes. For example:

```
{
  "sentTimestamp": "",
  "senderId": "",
  "orderDate": "2015/10/5",
  "orderDetails": "Ibuprofen, Acetaminophen",
  "orderId": 5
}
```

- `MySQSQueue_B` contains messages that have SNS metadata attributes in addition to the core message data.

```
{
  "Type": "Notification",
   "MessageId": "54d1d2e9-a4a9-5481-8a2e-8228b1ad7c05",
   ...
}
```

#### Develop SQS Consumer

In this section, you will develop an application that polls an SQS queue regularly. The application receives messages and deletes each message from the queue after processing it.

  For more information, see the [AmazonSQSClient API documentation](https://docs.aws.amazon.com/sdk-for-net/v3/developer-guide/sqs-apis-intro.html).

   Enable **long polling** (20 seconds) and set **maximum number** of messages to `10`.

   With long polling, the response to the receive message request will contain at least one of the available messages (if any) and up to the maximum number requested.

   For more information, see:

   - [ReceiveMessageRequest API documentation](http://docs.aws.amazon.com/sdkfornet1/latest/apidocs/html/T_Amazon_SQS_Model_ReceiveMessageRequest.htm).
   - [Amazon SQS Long Polling](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-long-polling.html)
   - [MaxNumberOfMessages](http://docs.aws.amazon.com/sdkfornet1/latest/apidocs/html/P_Amazon_SQS_Model_ReceiveMessageRequest_MaxNumberOfMessages.htm)

#### Goal 

Build a proof of concept .NET *SNS Publisher* and .NET *SQS Consumer* applications and deploy them to AWS using Visual Studio / Elastic Beanstalk. 