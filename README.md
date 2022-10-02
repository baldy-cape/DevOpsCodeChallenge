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

Login with credentials (user has AmazonEC2FullAccess) 

```
[~/storage/git/DevOpsCodeChallenge] $  aws configure
AWS Access Key ID [None]: XXXXXX
AWS Secret Access Key [None]: XXXXXX
Default region name [None]: 
Default output format [None]: 
```

## Deploy from Terraform

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
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-vpcs --filters Name=tag:Project,Values=DevOpsCodeChallenge
{
    "Vpcs": [
        {
            "CidrBlock": "10.0.0.0/16",
            "DhcpOptionsId": "dopt-90d023f9",
            "State": "available",
            "VpcId": "vpc-06399656f6e7fd216",
            "OwnerId": "231079812097",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-034c87687ccc94a41",
                    "CidrBlock": "10.0.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": false,
            "Tags": [
                {
                    "Key": "Project",
                    "Value": "DevOpsCodeChallenge"
                }
            ]
        }
    ]
}
```

## A private subnet

```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-subnets --filters Name=tag:Project,Values=DevOpsCodeChallenge
{
    "Subnets": [
        {
            "AvailabilityZone": "eu-north-1a",
            "AvailabilityZoneId": "eun1-az1",
            "AvailableIpAddressCount": 251,
            "CidrBlock": "10.0.1.0/24",
            "DefaultForAz": false,
            "MapPublicIpOnLaunch": false,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-0f117c3aaece275be",
            "VpcId": "vpc-06399656f6e7fd216",
            "OwnerId": "231079812097",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "Tags": [
                {
                    "Key": "Project",
                    "Value": "DevOpsCodeChallenge"
                }
            ],
            "SubnetArn": "arn:aws:ec2:eu-north-1:231079812097:subnet/subnet-0f117c3aaece275be",
            "EnableDns64": false,
            "Ipv6Native": false,
            "PrivateDnsNameOptionsOnLaunch": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            }
        }
    ]
}

```


## A public subnet
```
[~/storage/git/DevOpsCodeChallenge] $ aws ec2 describe-subnets  --filters Name=tag:Project,Values=DevOpsCodeChallenge  --query 'Subnets[?MapPublicIpOnLaunch==`true`]' 
[
    {
        "AvailabilityZone": "eu-north-1a",
        "AvailabilityZoneId": "eun1-az1",
        "AvailableIpAddressCount": 11,
        "CidrBlock": "10.0.2.0/28",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": true,
        "MapCustomerOwnedIpOnLaunch": false,
        "State": "available",
        "SubnetId": "subnet-038a0cb200a2ad001",
        "VpcId": "vpc-06399656f6e7fd216",
        "OwnerId": "231079812097",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "Project",
                "Value": "DevOpsCodeChallenge"
            }
        ],
        "SubnetArn": "arn:aws:ec2:eu-north-1:231079812097:subnet/subnet-038a0cb200a2ad001",
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
 *As a best practice, define permissions for only specific resources in specific accounts. Alternatively, you can grant least privilege using condition keys. Learn more*

```
[~/storage/git/DevOpsCodeChallenge] $ aws iam get-role --role-name S3AccessRole
{
    "Role": {
        "Path": "/",
        "RoleName": "S3AccessRole",
        "RoleId": "AROATLTLODQAT2SMSKBBX",
        "Arn": "arn:aws:iam::231079812097:role/S3AccessRole",
        "CreateDate": "2022-10-02T13:58:52Z",
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
        "RoleLastUsed": {}
    }
}

```

## An EC2 instance with the previously created role attached, inside the private subnet of the created VPC
## An EC2 instance with no role attached, inside the public subnet of the created VPC
## Bootstrap this instance with NGINX
## A load balancer in the public subnet of the created VPC Targeting the private EC2 instance
## A security group Attached to the created EC2 instances

# Task 2: Build a CI/CD pipeline to run your automation
Using a CI/CD tool provider of your choice, create a pipeline which will run the
automation configured in Task 1.
Requirements of this pipeline are as follows:
1. It should run only if commits have been pushed to the master branch
2. Multiple runs should not result in duplicated resources
3. Any automation commands that fail should cause the build to fail

# Bonus Task:
In order to showcase your approach to solving a less defined problem take a look at
the following exercise.
We want to scalably run a docker container which contains Nginx, design the
infrastructure which will fulfill this and provide the IaC in the same repository as the
tasks above.
