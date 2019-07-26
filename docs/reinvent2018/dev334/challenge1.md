## Create AWS resources using Powershell

#### Creating new VPC with a specific CIDR block

```powershell
$newvpc = New-EC2Vpc -CidrBlock 10.233.0.0/20 -InstanceTenancy default
$vpcid = $newvpc.vpcid
```

#### Tag the VPC we just created
```powershell
$vpctag=New-Object Amazon.EC2.Model.Tag
$vpctag.Key = "Name"
$vpctag.Value = "DEV334"
New-EC2Tag -resource $newvpc.VpcId -Tag $vpctag
```

#### Creating an Internet Gateway for internet access
```powershell
$igw = New-EC2InternetGateway | Add-EC2InternetGateway -VpcId $newvpc.VpcId
```

#### Check if Internet Gateway was created
```powershell
Get-EC2InternetGateway -Filter @{ Name="attachment.vpc-id"; Values="$vpcid" }
```

#### Find the Internet Gateway associated with newly created VPC and store it as a variable
```powershell
$igwid = (Get-EC2InternetGateway -filter @{ Name="attachment.vpc-id"; Values="$vpcid" }).InternetGatewayId
```

#### Find main Route Table that got created with VPC
```powershell
Get-EC2RouteTable -Filter @{ Name = "vpc-id"; Value = $newvpc.vpcid }
```

#### Store main Route Table in a variable
```powershell
$mainroutetable = Get-EC2RouteTable -Filter @{ Name = "vpc-id"; Value = $newvpc.vpcid }
```

> No need to create a new  route table since we can use $mainroutetable as public route table

#### Tag Route Table as Public
```powershell
$pubrttag=New-Object Amazon.EC2.Model.Tag
$pubrttag.Key = "Name"
$pubrttag.Value = "DEV334-PubRoute-1"
New-EC2Tag -Resource $mainroutetable.RouteTableId -Tag $pubrttag
```

#### Add Routes
```powershell
New-EC2Route -RouteTableId $mainroutetable.RouteTableId -DestinationCidrBlock 0.0.0.0/0 -GatewayId $igwid
```

#### Create Public Subnet
```powershell
$pubsub = New-EC2Subnet -VpcId $newvpc.vpcid -AvailabilityZone us-west-2a -CidrBlock 10.233.0.0/24
```

#### Register Public Subnet to Public Route Table
```powershell
Register-EC2RouteTable -RouteTableId $mainroutetable.RouteTableId -SubnetId $pubsub.SubnetId
```

#### Tag Public Subnet
```powershell
$pubsubtag=New-Object Amazon.EC2.Model.Tag
$pubsubtag.Key = "Name"
$pubsubtag.Value = "DEV334-PubSub-1"
New-EC2Tag -Resource $pubsub.subnetid -Tag $pubsubtag
```

#### Create NAT Gateway
> But first, create an Elastic IP for it
```powershell
$eipallocation = New-EC2Address -Domain Vpc
```

#### Check Elastic IP
```powershell
$eipallocation.AllocationId
```

#### Now Create NAT Gateway
```powershell
$ngw = New-EC2NatGateway -SubnetId $pubsub.SubnetId -AllocationId $eipallocation.AllocationId
```

#### Check status of NAT Gateway creation
> Wait for about 3 minutes for the NAT Gateway to be created
```powershell
(Get-EC2NatGateway -Filter @{ Name = "vpc-id"; Value = $newvpc.vpcid }).State
```

#### Wait till the result of this cmdlet shows NAT Gateway as Available
```powershell
$ngwid = (Get-EC2NatGateway | Where-Object {$_.State -eq 'available' -and $_.VpcId -eq $newvpc.VpcId}).NatGatewayId
```

#### Create Private Route Table
```powershell
$prirt = New-EC2RouteTable -VpcId $newvpc.VpcId
```

#### Tag Private Route Table
```powershell
$prirttag = New-Object Amazon.EC2.Model.Tag
$prirttag.Key = "Name"
$prirttag.Value = "DEV334-PriRoute-1"
New-EC2Tag -Resource $prirt.RouteTableId -Tag $prirttag
```

#### Route internet traffic through NAT Gateway for Private Subnet
```powershell
New-EC2Route -RouteTableId $prirt.RouteTableId -DestinationCidrBlock 0.0.0.0/0 -GatewayId $ngwid
```

#### Create Private Subnet
```powershell
$prisub = New-EC2Subnet -VpcId $newvpc.VpcId -AvailabilityZone us-west-2a -CidrBlock 10.233.11.0/24
```

#### Tag Private Subnet
```powershell
$prisubtag=New-Object Amazon.EC2.Model.Tag
$prisubtag.Key = "Name"
$prisubtag.Value = "DEV334-PriSub-1"
New-EC2Tag -Resource $prisub.subnetid -Tag $prisubtag
```


#### Register Private Subnet to Private Route table
```powershell
Register-EC2RouteTable -RouteTableId $prirt.RouteTableId -SubnetId $prisub.SubnetId
```

> Next, we are going to create the Security Group for EC2

#### Define Ports, Ingress, IP Range etc for SG
```powershell
$sgrdp1 = @{ IpProtocol="tcp"; FromPort="3389"; ToPort="3389"; IpRanges="0.0.0.0/0" }
$sghttp = @{ IpProtocol="tcp"; FromPort="80"; ToPort="80"; IpRanges="0.0.0.0/0" }
```

#### More Ports for Security Group if needed
```powershell
$sghttps = @{ IpProtocol="tcp"; FromPort="443"; ToPort="443"; IpRanges="0.0.0.0/0" }
```

#### Create SG
```powershell
New-EC2SecurityGroup -GroupName DEV334-win-sg-1 -Description "SG for Builder Session" -VpcId $newvpc.VpcId
```

#### Make sure Security Group has been created
> If the following cmdlet doesn't return a Group ID, SG was not created as expected. Ask for help.
```powershell
(Get-EC2SecurityGroup -Filter @{ Name = "group-name"; Value = "DEV334-win-sg-1" }).GroupID
```
> Store Security Group ID to a variable
```powershell
$newsg = (Get-EC2SecurityGroup -Filter @{ Name = "group-name"; Value = "DEV334-win-sg-1" }).GroupID
```

#### Grant ingress access in Security Group
```powershell
Grant-EC2SecurityGroupIngress -GroupId $newsg -IpPermission @( $sghttp, $sgrdp1 )
```

#### Grant egress access in SG (allow-all to keep it stateful)

> When SG is created, it automatically allows all egress access. This is what makes a security group stateful. You can edit it to make it more restrictive or stateful for fewer ports and IP ranges, if needed.

#### Create PEM key for EC2
> Mac users, change the .pem file path to an appropriate location
```powershell
(New-EC2KeyPair -KeyName "DEV334-builder-session-key").KeyMaterial | Out-File C:\DEV334-builder-session-key.pem
```

#### Create Windows 2016 EC2 instance
> Use this AMI for EC2
```powershell
$ami = Get-EC2ImageByName WINDOWS_2016_BASE
```
> Check if you have an AMI with above name. If the result is empty, AMI with the specified name doesn't exist. Ask for help.
```powershell
$ami.ImageId
```

#### Create Tag for EC2
```powershell
$ec2tag1 = @{ Key="Name"; Value="Win-2016-With-IIS" }
$ec2tagspec = New-Object Amazon.EC2.Model.TagSpecification
$ec2tagspec.ResourceType = "instance"
$ec2tagspec.Tags.Add($ec2tag1)
New-EC2Tag -Resource $ami.ImageId -Tag $ec2tag1
```

#### Auto assign IPv4 since we need a public IP to log into EC2
```powershell
Edit-EC2SubnetAttribute -SubnetId $pubsub.SubnetId -MapPublicIpOnLaunch $true
```
#### Setup IIS and the sample website

> Copy the following script to a text file on your laptop and save it as IISConfig.txt

```powershell
<powershell>
Set-ExecutionPolicy Bypass -Scope Process -Force

# Save machine name for messages
[string]$vm = $Env:Computername

# Check for IIS presence and installo, if needed
if ((Get-WindowsFeature Web-Server).InstallState -ne "Installed") 
    {
    Write-Host "IIS is not installed on $vm - installing"
    Install-WindowsFeature web-server -IncludeManagementTools
    } 
 Write-Host "IIS is  installed on $vm"

 # Remove files of the default web site
Remove-Item "C:/inetpub/wwwroot/*.*"

# New HTML file defined as hash table inside the script
# (in real life we would probably copy site from some bucket or share)
$Page =
       @(
        ' <html>
<h1 style="font-size: 75px;font-family: Arial, Helvetica, sans-serif; text-align: center;" >Congratulations!</h1>
<h2 style="font-size: 25px;font-family: Arial, Helvetica, sans-serif; text-align: center" >You have successfully completed the exercise DEV334 - Powershell tools for AWS</h2>
<svg style="width:100%;height:700px;">
    <path class="path" fill="none" stroke="orange" stroke-width="5" stroke-miterlimit="10" d="M989,595H712v-35c0,0,4.5-1.8,8-3
                                                                                                  c5.2-1.8,12.5,5.3,22-4c3.4-3.4-0.9-7.8-0.4-10.1c0.7-3.1,4.4-6.8,1.6-11.4c-2.6-4.2-6.9-3.6-8.2-5.5c-1.7-2.3-2.2-6.3-7-9
                                                                                                  c-5.6-3.1-9.9,0.2-13-1c-2.5-0.9-2.3-5-9-5c-4.8,0-7.2,4.8-10,5c-2.3,0.2-4.9-4.5-10-2c-5.5,2.8-4,7.3-6,9c-1.4,1.2-3.1,3.2-6,4.2
                                                                                                  c-2.6,0.9-4.9,3-4,8.8c0.6,3.7,6.8,4.1,7.5,6c1,2.9-6.4,6.2-2.5,12c3,4.5,9,1.6,12,1c1.9-0.4,7.1-0.7,8,0c3.4,2.5,9,5,9,5v35
                                                                                                  l-506-1.5L182.3,444l0.3-0.8v-69.6l-0.2-0.2l12.3-72.3c10.9-2.6,16.5-6.5,16.5-6.5l-5.2-2.9l1.1-5.8l15-3.3l-10.1-3.9l1.2-4.6
                                                                                                  c-15.8-8.3-32.2-11-32.2-11v-3.6l4.1-6.5h-4.9v-4.4h-8.3V244h-1.2l-1.7-31.2l-1-1.3l-1,1.3l-1.7,31.2h-1.2v4.8h-8.3v4.4h-4.9
                                                                                                  l4.1,6.5v3.6c0,0-16.5,2.7-32.2,11l1.2,4.6l-10.1,3.9l15,3.3l1.1,5.8l-5.1,2.9c0,0,5.5,3.9,16.4,6.5l12.3,72.4l-0.1,0.1v69.6
                                                                                                  l0.3,0.8l-14.6,149.4h-1.2H-11" />

    <path class="path" fill="grey" stroke="orange" stroke-width="2" stroke-miterlimit="10" d="M8,393.7c0-13.5,12.1-10.8,15.6-14.7
                                                                                                  c2.8-3.2-1-8.8,9-13.9c7.9-4.1,9.7,1,13.1,0.8c4.5-0.3,3.3-6.7,14.7-6.6c12.7,0.2,11.2,8.4,14.7,10.6c3,1.9,7.9-2.1,13.9,4.1
                                                                                                  c3.8,4,1.3,7.4,2.5,9.8c2.2,4.4,14.7,0.9,14.7,13.9c0,12.2-13.5,8.3-17.2,10.6c-3.6,2.3-4.4,9.3-13.1,11.5c-8,2-9.5-4-13.9-4.1
                                                                                                  c-5-0.1-5.5,8.6-18.8,6.6c-12.3-1.9-12.3-9.1-16.4-12.3C21.9,406.3,8,408.6,8,393.7z" />


    <path class="path" fill="lightgrey" stroke="orange" stroke-width="2" stroke-miterlimit="10" d="M325.1,313.9c-3.9,3-3.9,10-15.7,11.8
                                                                                                  c-12.8,2-13.3-6.4-18-6.3c-4.3,0.1-5.7,5.8-13.3,3.9c-8.4-2.1-9.1-8.8-12.5-11c-3.6-2.3-16.5,1.5-16.5-10.2c0-12.4,12-9.1,14.1-13.3
                                                                                                  c1.1-2.3-1.3-5.6,2.4-9.4c5.8-6,10.4-2.1,13.3-3.9c3.4-2.1,2-10,14.1-10.2c11-0.2,9.9,6,14.1,6.3c3.3,0.2,5-4.7,12.5-0.8
                                                                                                  c9.6,4.9,6,10.3,8.6,13.3c3.3,3.7,14.9,1.2,14.9,14.1C343.1,312.5,329.8,310.3,325.1,313.9z" />

    <path class="path" fill="lightgrey" stroke="orange" stroke-width="2" stroke-miterlimit="10" d="M18.4,229.5c0-13.5,12.1-10.8,15.6-14.7
                                                                                                  c2.8-3.2-1-8.8,9-13.9c7.9-4.1,9.7,1,13.1,0.8c4.5-0.3,3.3-6.7,14.7-6.6c12.7,0.2,11.2,8.4,14.7,10.6c3,1.9,7.9-2.1,13.9,4.1
                                                                                                  c3.8,4,1.3,7.4,2.5,9.8c2.2,4.4,14.7,0.9,14.7,13.9c0,12.2-13.5,8.3-17.2,10.6c-3.6,2.3-4.4,9.3-13.1,11.5c-8,2-9.5-4-13.9-4.1
                                                                                                  c-5-0.1-5.5,8.6-18.8,6.6c-12.3-1.9-12.3-9.1-16.4-12.3C32.2,242.1,18.4,244.4,18.4,229.5z" />

    <path class="path" fill="grey" stroke="orange" stroke-width="2" stroke-miterlimit="10" d="M215.8,398.8c0-13.5,12.1-10.8,15.6-14.7
                                                                                                  c2.8-3.2-1-8.8,9-13.9c7.9-4.1,9.7,1,13.1,0.8c4.5-0.3,3.3-6.7,14.7-6.6c12.7,0.2,11.2,8.4,14.7,10.6c3,1.9,7.9-2.1,13.9,4.1
                                                                                                  c3.8,4,1.3,7.4,2.5,9.8c2.2,4.4,14.7,0.9,14.7,13.9c0,12.2-13.5,8.3-17.2,10.6c-3.6,2.3-4.4,9.3-13.1,11.5c-8,2-9.5-4-13.9-4.1
                                                                                                  c-5-0.1-5.5,8.6-18.8,6.6c-12.3-1.9-12.3-9.1-16.4-12.3C229.7,411.3,215.8,413.6,215.8,398.8z" />

</svg> 
</html>'
        )
Set-Content "C:/inetpub/wwwroot/Index.html" -Value $Page
</powershell>
```

#### Create Windows EC2 instance

> Make sure you give the correct local path of the IISConfig.txt file you created in the above step

```powershell
$script = Get-Content -Raw C:\<Path>\IISConfig.txt
$userdata = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Script))
```

#### Create EC2 instance and pass PS Userdata file to Install IIS
```powershell
New-EC2Instance -ImageId $ami.ImageId -InstanceType t2.large -SubnetId $pubsub.SubnetId -KeyName DEV334-builder-session-key -SecurityGroupId $newsg -UserData $userdata -Tagspecification $ec2tagspec
```
#### Get IP address of the newly created EC2 instance
```powershell
(Get-EC2Instance -Filter @{Name="vpc-id";Value=$vpcid}).Instances | Select-Object -Property PublicIpAddress
```

#### Test the website
> It takes about 5 minutes for the EC2 Windows instance to be created.

Open your browser on the local machine and navigate to http://<Public IP of EC2>