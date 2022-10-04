# Setup
## Install Terraform 
Following https://learn.hashicorp.com/tutorials/terraform/install-cli

```
[~/storage/git/DevOpsCodeChallenge] $ sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
Adding repo from: https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
(laurence@carbon) Fri Sep 30 11:09:39
[~/storage/git/DevOpsCodeChallenge] $  sudo dnf -y install terraform
```

### Check version 
```
 $ terraform -v
Terraform v1.3.1
on linux_amd64
```
## AWS configure
Install awscli if required

    $ sudo yum install awscli



### Persmissions for AWS user
- AmazonEC2FullAccess
- IAM Full: List, Read, Write, Permissions management Limited: Tagging

### Login with credentials
```
[~/storage/git/DevOpsCodeChallenge] $  aws configure
AWS Access Key ID [None]: XXXXXX
AWS Secret Access Key [None]: XXXXXX
Default region name [None]: 
Default output format [None]: 
```

# Deploy from Terraform

### Initialize Terraform
    [~/storage/git/DevOpsCodeChallenge] $ terraform init

### Format and validate 
```
[~/storage/git/DevOpsCodeChallenge] $ terraform fmt
[~/storage/git/DevOpsCodeChallenge] $ terraform validate
Success! The configuration is valid.
```

### Apply

    [~/storage/git/DevOpsCodeChallenge] $ terraform apply


## Reference Bookmarks
* [Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)



# Task 1: Automate the creation of the following resources
## A VPC

```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-vpcs --filters Name=tag:project,Values=DevOpsCodeChallenge
{
    "Vpcs": [
        {
            "CidrBlock": "10.0.0.0/16",
            "DhcpOptionsId": "dopt-90d023f9",
            "State": "available",
            "VpcId": "vpc-067c30b1e784f5b52",
            "OwnerId": "231079812097",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-0c4959ab725ff1252",
                    "CidrBlock": "10.0.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": false,
            "Tags": [
                {
                    "Key": "project",
                    "Value": "DevOpsCodeChallenge"
                }
            ]
        }
    ]
}

```

## A private subnet

```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-subnets  --filters Name=tag:project,Values=DevOpsCodeChallenge  --query 'Subnets[?MapPublicIpOnLaunch==`false`]' 
[
    {
        "AvailabilityZone": "eu-north-1c",
        "AvailabilityZoneId": "eun1-az3",
        "AvailableIpAddressCount": 249,
        "CidrBlock": "10.0.1.0/24",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "MapCustomerOwnedIpOnLaunch": false,
        "State": "available",
        "SubnetId": "subnet-0afd55bcdad77c3ba",
        "VpcId": "vpc-067c30b1e784f5b52",
        "OwnerId": "231079812097",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "project",
                "Value": "DevOpsCodeChallenge"
            }
        ],
        "SubnetArn": "arn:aws:ec2:eu-north-1:231079812097:subnet/subnet-0afd55bcdad77c3ba",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        }
    }
]

```


## A public subnet
```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-subnets  --filters Name=tag:project,Values=DevOpsCodeChallenge  --query 'Subnets[?MapPublicIpOnLaunch==`true`]' 
[
    {
        "AvailabilityZone": "eu-north-1a",
        "AvailabilityZoneId": "eun1-az1",
        "AvailableIpAddressCount": 250,
        "CidrBlock": "10.0.2.0/24",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": true,
        "MapCustomerOwnedIpOnLaunch": false,
        "State": "available",
        "SubnetId": "subnet-0abe2573c8ba7bd80",
        "VpcId": "vpc-067c30b1e784f5b52",
        "OwnerId": "231079812097",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "project",
                "Value": "DevOpsCodeChallenge"
            }
        ],
        "SubnetArn": "arn:aws:ec2:eu-north-1:231079812097:subnet/subnet-0abe2573c8ba7bd80",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        }
    }
]
```


## An IAM role with S3 access

 *As a best practice, define permissions for only specific resources in specific accounts. Alternatively, you can grant least privilege using condition keys. Learn more....*

```
[~/storage/git/DevOpsCodeChallenge] $ aws iam get-role --role-name S3Access
{
    "Role": {
        "Path": "/",
        "RoleName": "S3Access",
        "RoleId": "AROATLTLODQA64HMUFCUX",
        "Arn": "arn:aws:iam::231079812097:role/S3Access",
        "CreateDate": "2022-10-03T14:51:27Z",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        },
        "MaxSessionDuration": 3600,
        "Tags": [
            {
                "Key": "project",
                "Value": "DevOpsCodeChallenge"
            }
        ],
        "RoleLastUsed": {}
    }
}

```

## An EC2 instance with the previously created role attached, inside the private subnet of the created VPC
```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-instances --filters Name=tag:Name,Values=private 
{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-0bcf2639b551f6b31",
                    "InstanceId": "i-05e446ae799d87202",
                    "InstanceType": "t3.nano",
                    "KeyName": "delta",
                    "LaunchTime": "2022-10-03T14:58:21.000Z",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "Placement": {
                        "AvailabilityZone": "eu-north-1c",
                        "GroupName": "",
                        "Tenancy": "default"
                    },
                    "PrivateDnsName": "ip-10-0-1-13.eu-north-1.compute.internal",
                    "PrivateIpAddress": "10.0.1.13",
...
```

## An EC2 instance with no role attached, inside the public subnet of the created VPC
```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-instances --filters Name=tag:Name,Values=public 
{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-0bcf2639b551f6b31",
                    "InstanceId": "i-06f51dc7759532396",
                    "InstanceType": "t3.nano",
                    "KeyName": "delta",
                    "LaunchTime": "2022-10-03T14:51:40.000Z",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "Placement": {
                        "AvailabilityZone": "eu-north-1a",
                        "GroupName": "",
                        "Tenancy": "default"
                    },
                    "PrivateDnsName": "ip-10-0-2-127.eu-north-1.compute.internal",
                    "PrivateIpAddress": "10.0.2.127",
                    "ProductCodes": [],
                    "PublicDnsName": "",
                    "PublicIpAddress": "16.171.47.87",
...
```

## Bootstrap this instance with NGINX
Bootstrapped using shell script bootstrap-nginx.sh in data_entry option 
```
[~/storage/git/DevOpsCodeChallenge] $ ssh ec2-user@13.53.171.105
The authenticity of host '13.53.171.105 (13.53.171.105)' can't be established.
ED25519 key fingerprint is SHA256:rwyo0ZoaIbr3Q05KNT0AFX0poNJYVJ1vzuhMvOzEQ0Q.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '13.53.171.105' (ED25519) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-10-0-2-53 ~]$ rpm -qa | grep ngin
nginx-filesystem-1.20.0-2.amzn2.0.5.noarch
nginx-1.20.0-2.amzn2.0.5.x86_64
[ec2-user@ip-10-0-2-53 ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2022-10-03 15:35:14 UTC; 2min 8s ago

```
## A load balancer in the public subnet of the created VPC Targeting the private EC2 instance
Created a network load balancer targeting SSH service on private instance.

```
[~/storage/git/DevOpsCodeChallenge] $ aws elbv2 describe-load-balancers  | grep DNS
            "DNSName": "tf-lb-20221003153428508600000005-ac3d82dff9a0ae00.elb.eu-north-1.amazonaws.com",

~/storage/git/DevOpsCodeChallenge] $ ssh ec2-user@tf-lb-20221003153428508600000005-ac3d82dff9a0ae00.elb.eu-north-1.amazonaws.com /sbin/route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.0.1.1        0.0.0.0         UG    0      0        0 eth0
10.0.1.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.169.254 0.0.0.0         255.255.255.255 UH    0      0        0 eth0

```

## A security group Attached to the created EC2 instances
```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-security-groups  --filters Name=tag:project,Values=DevOpsCodeChallenge | grep GroupName
            "GroupName": "terraform-20221003153427731000000004",
(laurence@carbon) Mon Oct 03 18:02:33
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-instances | grep -A4 SecurityGroups
                    "SecurityGroups": [
                        {
                            "GroupName": "terraform-20221003153427731000000004",
                            "GroupId": "sg-01fe3d2f11469ab46"
                        }
--
                    "SecurityGroups": [
                        {
                            "GroupName": "terraform-20221003153427731000000004",
                            "GroupId": "sg-01fe3d2f11469ab46"
                        }

```

# Task 2: Build a CI/CD pipeline to run your automation
```
Using a CI/CD tool provider of your choice, create a pipeline which will run the
automation configured in Task 1.

```
## Setup
### Terraform Cloud
Following https://learn.hashicorp.com/tutorials/terraform/github-actions?in=terraform/automation

- Create workspace 
- Add AWS Credintials
- Create API Token

### Github 
- Add TF_API_TOKEN to Repo secrets
- Create .github/workflows/terraform.yml 
- Edit main.tf adding cloud section 

## Requirements of this pipeline are as follows:
1. It should run only if commits have been pushed to the master branch
From .github/workflows/terraform.yml
```
name: "Terraform"

on:
  push:
    branches:
      - main
```

2. Multiple runs should not result in duplicated resources

Using Terraform cloud the state is stored avoiding duplicate resoures when run from multiple locations. 

3. Any automation commands that fail should cause the build to fail
#### Edit main.tf
Make change to main.tf so that terraform fmt -check fails
```
(laurence@carbon) Tue Oct 04 11:01:46
[~/storage/git/DevOpsCodeChallenge] $ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
(laurence@carbon) Tue Oct 04 11:02:40
[~/storage/git/DevOpsCodeChallenge] $ git checkout master
Switched to branch 'master'
Your branch is ahead of 'origin/master' by 1 commit.
  (use "git push" to publish your local commits)
(laurence@carbon) Tue Oct 04 11:02:46
[~/storage/git/DevOpsCodeChallenge] $ vim main.tf 
(laurence@carbon) Tue Oct 04 11:02:55
[~/storage/git/DevOpsCodeChallenge] $ terraform fmt -check; echo $?
main.tf
3
```

#### Push change to master
```
(laurence@carbon) Tue Oct 04 11:03:07
[~/storage/git/DevOpsCodeChallenge] $ git commit -a -m"Broke main.tf formatting"
[master d05cd05] Broke main.tf formatting
 Committer: Laurence Baldwin <laurence@carbon.lancia.za.org>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly. Run the 
following command and follow the instructions in your editor to edit
your configuration file:

    git config --global --edit

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 1 file changed, 1 insertion(+), 1 deletion(-)
(laurence@carbon) Tue Oct 04 11:03:36
[~/storage/git/DevOpsCodeChallenge] $ git push
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 8 threads
Compressing objects: 100% (7/7), done.
Writing objects: 100% (7/7), 1.04 KiB | 532.00 KiB/s, done.
Total 7 (delta 5), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (5/5), completed with 4 local objects.
To github.com:baldy-cape/DevOpsCodeChallenge.git
   06b03e3..d05cd05  master -> master
```
#### Confirm run fails
From github actions 
https://github.com/baldy-cape/DevOpsCodeChallenge/actions/runs/3181209918/jobs/5185692914
```
Run terraform fmt -check
/home/runner/work/_temp/b66f13f2-0926-4f56-b077-f3d3bd209585/terraform-bin fmt -check
main.tf



Error: Terraform exited with code 3.
Error: Process completed with exit code 1.
```

## Oneliner test for public nginx
```
[~/storage/git/DevOpsCodeChallenge] $ curl  http://$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --output text --filters Name=tag:Name,Values=public)
<h1>DevOps Code Challenge</H1>Tue Oct  4 09:19:19 UTC 2022
```


# Bonus Task:
```
In order to showcase your approach to solving a less defined problem take a look at
the following exercise.
We want to scalably run a docker container which contains Nginx, design the
infrastructure which will fulfill this and provide the IaC in the same repository as the
tasks above.
```

My approach would be to utilise a Kubernetes as a service product such as GKE autopilot. 

This reduces the amount of infrastructure that needs to be maintained. 

## Create Cluster 
```
gcloud container clusters create-auto DevOpsCodeChallenge-cluster
```

## Deploy nginx 
```
[~/storage/git/DevOpsCodeChallenge/bonus] $ kubectl apply -f nginx.yaml 
...
[~/storage/git/DevOpsCodeChallenge/bonus] $ kubectl get pods | grep nginx
W1004 11:30:51.279915 3352685 gcp.go:119] WARNING: the gcp auth plugin is deprecated in v1.22+, unavailable in v1.26+; use gcloud instead.
To learn more, consult https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
nginx-deployment-74d589986c-7dcz2   1/1     Running             0          83s
nginx-deployment-74d589986c-8f7rz   0/1     ContainerCreating   0          83s
```
## Test Access
```
[~/storage/git/DevOpsCodeChallenge/bonus] $ kubectl get service | grep nginx
W1004 11:42:08.763057 3353686 gcp.go:119] WARNING: the gcp auth plugin is deprecated in v1.22+, unavailable in v1.26+; use gcloud instead.
To learn more, consult https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
nginx        LoadBalancer   10.48.2.170   34.88.40.31   80:31742/TCP   5m48s
(laurence@carbon) Tue Oct 04 11:42:09
[~/storage/git/DevOpsCodeChallenge/bonus] $ curl 34.88.40.31
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
## Scale 
Double the number of containers running nginx
```
[~/storage/git/DevOpsCodeChallenge/bonus] $ kubectl scale --replicas=4 deployment nginx-deployment 
W1004 11:45:10.137775 3354006 gcp.go:119] WARNING: the gcp auth plugin is deprecated in v1.22+, unavailable in v1.26+; use gcloud instead.
To learn more, consult https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
deployment.apps/nginx-deployment scaled
(laurence@carbon) Tue Oct 04 11:45:10
[~/storage/git/DevOpsCodeChallenge/bonus] $ kubectl get pods | grep nginx
W1004 11:45:20.535406 3354030 gcp.go:119] WARNING: the gcp auth plugin is deprecated in v1.22+, unavailable in v1.26+; use gcloud instead.
To learn more, consult https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
nginx-deployment-74d589986c-7dcz2   1/1     Running             0          15m
nginx-deployment-74d589986c-8f7rz   1/1     Running             0          15m
nginx-deployment-74d589986c-m9g6t   0/1     ContainerCreating   0          10s
nginx-deployment-74d589986c-szmvb   1/1     Running             0          10s
```
