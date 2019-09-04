* Practicing CI/CD on AWS <https://d1.awsstatic.com/whitepapers/DevOps/practicing-continuous-integration-continuous-delivery-on-AWS.pdf>


## Appendix 

Ideally the developer should not have full admin permissions but rather access to the below resources:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "codepipeline:PutApprovalResult",
                "codepipeline:UpdatePipeline",
                "codepipeline:CreatePipeline"
            ],
            "Resource": "*",
            "Effect": "Deny"
        },
  {
            "Action": [
                "codepipeline:*"

            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:listprojects",
                "cloudformation:CreateUploadBucket",
                "cloudformation:GetTemplateSummary",
                "codecommit:ListRepositories",
                "cloudformation:ListStacks",
                "cloudformation:DescribeStacks",
                "codepipeline:ListPipelines",
                "cloudformation:GetTemplateSummary",
                "servicecatalog:DescribeProduct",
                "servicecatalog:DescribeProductView",
                "servicecatalog:DescribeProvisioningParameters",
                "servicecatalog:ListLaunchPaths",
                "servicecatalog:ProvisionProduct",
                "servicecatalog:SearchProducts"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Condition": {
                "StringEquals": {
                    "servicecatalog:userLevel": "self"
                }
            },
            "Action": [
                "servicecatalog:DescribeProvisionedProduct",
                "servicecatalog:DescribeRecord",
                "servicecatalog:ListRecordHistory",
                "servicecatalog:ScanProvisionedProducts",
                "servicecatalog:TerminateProvisionedProduct",
                "servicecatalog:UpdateProvisionedProduct",
                "servicecatalog:SearchProvisionedProducts",
                "servicecatalog:CreateProvisionedProductPlan",
                "servicecatalog:DescribeProvisionedProductPlan",
                "servicecatalog:ExecuteProvisionedProductPlan",
                "servicecatalog:DeleteProvisionedProductPlan",
                "servicecatalog:ListProvisionedProductPlans"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::cf-templates-*",
                "arn:aws:s3:::cf-templates-*/*",
                "arn:aws:s3:::sc-*",
                "arn:aws:s3:::sc-*/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:Get*"
            ],
            "Resource": [
                "arn:aws:s3:::vending-pipeline*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        }
    ]
}
```
