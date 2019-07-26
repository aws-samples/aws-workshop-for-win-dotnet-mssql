# Challenge 2

You work for a company that hosts all their servers in EC2. They want to make sure that IIS is installed on all the Instances that have tage named 'Role' with value of 'Frontend' For this they want to use AWS SSM run command. 

## Tools description

*AWS Systems Manager Run Command*: AWS Systems Manager Run Command lets you remotely and securely manage the configuration of your managed instances. Use Run Command to perform on-demand changes like updating applications or running Linux shell scripts and Windows PowerShell commands on a target set of dozens or hundreds of instances.

## Hints

Use AWS Systems Manager Run Command console and find the document that allows you to run Powershell scripts on your Windows instances. The Powershell command to install IIS is:
```
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
```


## References

[Running Commands Using Systems Manager Run Command](https://docs.aws.amazon.com/systems-manager/latest/userguide/run-command.html)

[AWS Systems Manager State Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state.html)

[Creating Associations that Execute MOF Files](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state-manager-using-mof-file.html)

[AWS Systems Manager Configuration Compliance](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-compliance.html)

[Write-SSMComplianceItem Cmdlet](https://docs.aws.amazon.com/powershell/latest/reference/items/Write-SSMComplianceItem.html)
