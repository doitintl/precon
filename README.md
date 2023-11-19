# Preconsolidation Script:

This is a simple AWS CLI Shell Script that can be used to get details around below Pre Consolidation Questions for AWS Prospect and Incoming New Customers.

# Any Risk Involved in Running this Script in Root Account?

There is zero risk when you check the code all CLI commands are list commands and the script is not doing any modification to any of resources in the AWS Account.

# This Script Covers below Pre Consolidation questions:

1. Customer has AWS Organization enabled?
2. How many accounts are there in the AWS organization?
3. Does any account in the AWS Organization has a bill above $50,000 in the last month?
4. List all the AWS Org services that are enabled in the Master Org Account.
5. Check and list the workloads running in the customer's master payer account.
6. What level of AWS Support does the account have?
7. Check if AWS Identity Center is enabled.
8. Check for Applied AWS Service Control Policies (SCP).
9. Check for AWS Marketplace listings.
10. Check if cost allocation tags are enabled.

# Prerequisite to Run This Script:

1. Script needs to be executed by only the root user.
2. Cost explorer should be enabled by customer (**If not then do manual pre consolidation**)

# How to Run this script:

1. Login to AWS console as root user.
2. Open AWS Cloud Shell Located at top right.

   <img width="1266" alt="Screenshot 2023-11-19 at 6 23 30 PM" src="https://github.com/doitintl/precon/assets/17955377/64c378f3-c953-4bd4-9aa4-4141bdcfdbeb">

3. Run This Command

   ```bash <(curl -Ls https://raw.githubusercontent.com/doitintl/precon/main/details.sh)```

4. Email the output if the script to the DOIT Representative.

# Sample Output

**Standalone AWS Account:**

```
[cloudshell-user@ip-10-130-86-122 ~]$ bash <(curl -Ls https://raw.githubusercontent.com/doitintl/precon/main/details.sh)
Collecting information from AWS...
AWS Organization is not enabled.
Customer does not have AWS Organization and will need a new MPA.
Checking for AWS Identity Center:
No, AWS Identity Center is not enabled.
Checking for AWS SCPs:
An error occurred (AWSOrganizationsNotInUseException) when calling the ListPolicies operation: Your account is not a member of an organization.
Checking for AWS Marketplace listings:
No marketplace listing found.
Checking for cost allocation tags:
Cost allocation tags are not enabled or no tags are set.
Information gathering complete.
```

**AWS Account with Organization Enabled:**

```[cloudshell-user@ip-10-138-188-104 ~]$ bash <(curl -Ls https://raw.githubusercontent.com/doitintl/precon/main/details.sh)
Collecting information from AWS...
AWS Organization is enabled.
Number of accounts in the AWS organization:
4
Checking if any account has a bill above 50,000 in the last month:
No account above 50K monthly.
Customer has AWS Organization.
List of enabled AWS Org services:
-------------------------------------
|ListAWSServiceAccessForOrganization|
+-----------------------------------+
|  cloudtrail.amazonaws.com         |
|  config.amazonaws.com             |
|  controltower.amazonaws.com       |
|  securityhub.amazonaws.com        |
|  sso.amazonaws.com                |
+-----------------------------------+
Checking for workloads in the master payer account:
Yes, there are EC2 instances running in the root account.
No workloads detected in the root account.
AWS Support Plan for the account:
The account is likely on the Basic or Developer support plan.
Checking for AWS Identity Center:
No, AWS Identity Center is not enabled.
Checking for AWS SCPs:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                                                       ListPolicies                                                                                                       |
+--------------------------------------------------------------------------------------------+-------------+----------------------------------------+------------------+------------------------+--------------------------+
|                                             Arn                                            | AwsManaged  |              Description               |       Id         |         Name           |          Type            |
+--------------------------------------------------------------------------------------------+-------------+----------------------------------------+------------------+------------------------+--------------------------+
|  arn:aws:organizations::aws:policy/service_control_policy/p-FullAWSAccess                  |  True       |  Allows access to every operation      |  p-FullAWSAccess |  FullAWSAccess         |  SERVICE_CONTROL_POLICY  |
|  arn:aws:organizations::622636313538:policy/o-k1r3qb8a3c/service_control_policy/p-zzspmted |  False      |  Guardrails applied to an organization |  p-zzspmted      |  aws-guardrails-NwTpKU |  SERVICE_CONTROL_POLICY  |
|  arn:aws:organizations::622636313538:policy/o-k1r3qb8a3c/service_control_policy/p-051g8d1g |  False      |  Guardrails applied to an organization |  p-051g8d1g      |  aws-guardrails-lELuzo |  SERVICE_CONTROL_POLICY  |
|  arn:aws:organizations::622636313538:policy/o-k1r3qb8a3c/service_control_policy/p-f7jg3vc1 |  False      |  Guardrails applied to an organization |  p-f7jg3vc1      |  aws-guardrails-TgTtEc |  SERVICE_CONTROL_POLICY  |
+--------------------------------------------------------------------------------------------+-------------+----------------------------------------+------------------+------------------------+--------------------------+
Checking for AWS Marketplace listings:
No marketplace listing found.
Checking for cost allocation tags:
Cost allocation tags are not enabled or no tags are set.
Information gathering complete.
```
