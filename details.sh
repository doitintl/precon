#!/bin/bash
echo "Collecting information from AWS..."

# Check if AWS Organization is enabled
if aws organizations describe-organization --query 'Organization' &> /dev/null; then
    echo "AWS Organization is enabled."

    # 1. How many accounts are there in the AWS organization?
    echo "Number of accounts in the AWS organization:"
    aws organizations list-accounts --query 'Accounts[*].Id' --output text | wc -w

    # 2. Does any account have a bill above $50,000 in the last month?
    echo "Checking if any account has a bill above 50,000 in the last month:"
    start_date=$(date -d "-1 month -$(($(date +%d)-1)) days" +%Y-%m-%d)
    end_date=$(date -d "-$(date +%d) days" +%Y-%m-%d)
    accounts_over_50k=$(aws ce get-cost-and-usage --time-period Start=$start_date,End=$end_date \
                                                  --granularity MONTHLY \
                                                  --metrics "UnblendedCost" \
                                                  --group-by Type=DIMENSION,Key=LINKED_ACCOUNT \
                                                  --output json | jq -r '.ResultsByTime[].Groups[] | select((.Metrics.UnblendedCost.Amount | tonumber) > 50000) | .Keys[]')
    if [ -z "$accounts_over_50k" ]; then
        echo "No account above 50K monthly."
    else
        echo "Accounts with a bill over 50,000 in the last month: $accounts_over_50k"
    fi

    # 3. Confirming the customer has an AWS Org
    echo "Customer has AWS Organization."

    # 5. List all the AWS Org services that are enabled
    echo "List of enabled AWS Org services:"
    aws organizations list-aws-service-access-for-organization --query 'EnabledServicePrincipals[*].ServicePrincipal' --output table

    echo "Checking for workloads in the master payer account:"
workload_found=false

# Check for EC2 instances
if aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text | grep -q 'i-'; then
    echo "Yes, there are EC2 instances running in the root account."
    workload_found=true
fi

# Check for RDS instances
if aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text | grep -q 'db-'; then
    echo "Yes, there are RDS instances running in the root account."
    workload_found=true
fi

# Check for EKS clusters
if aws eks list-clusters --query 'clusters' --output text | grep -q '.'; then
    echo "Yes, there are EKS clusters running in the root account."
    workload_found=true
fi

# Check for ECS clusters
if aws ecs list-clusters --query 'clusterArns' --output text | grep -q 'cluster'; then
    echo "Yes, there are ECS clusters running in the root account."
    workload_found=true
fi

# Check for API Gateway instances
if aws apigateway get-rest-apis --query 'items[*].id' --output text | grep -q '.*'; then
    echo "Yes, there are API Gateway instances running in the root account."
    workload_found=true
fi

# If no workloads are found, then output the message
if [ "$workload_found" = false ]; then
    echo "No workloads detected in the root account."
fi


    # 8. What level of AWS Support does the account have?
    echo "AWS Support Plan for the account:"
    if aws support describe-trusted-advisor-checks --language en &> /dev/null; then
        echo "The account is likely on the Business or Enterprise support plan."
    else
        error_message=$(aws support describe-trusted-advisor-checks --language en 2>&1)
        if [[ "$error_message" == *"SubscriptionRequiredException"* ]]; then
            echo "The account is likely on the Basic or Developer support plan."
        else
            echo "Unable to determine the support plan due to an unexpected error:"
            echo "$error_message"
        fi
    fi

else
    echo "AWS Organization is not enabled."
    echo "Customer does not have AWS Organization and will need a new MPA."
    # Skipping #1, #2, #5, #7, and #8 as AWS Organization is not enabled
fi

# 4. Check for AWS Identity Center
echo "Checking for AWS Identity Center:"
identity_center_instances=$(aws sso-admin list-instances --query 'Instances' --output json)
if [ "$identity_center_instances" != "[]" ]; then
    echo "Yes, AWS Identity Center is enabled."
else
    echo "No, AWS Identity Center is not enabled."
fi

# 6. Check for AWS SCPs
echo "Checking for AWS SCPs:"
aws organizations list-policies --filter "SERVICE_CONTROL_POLICY" --query 'Policies' --output table

# 9. Check for AWS Marketplace listings
echo "Checking for AWS Marketplace listings:"
start_date=$(date -d "-1 month -$(($(date +%d)-1)) days" +%Y-%m-%d)
end_date=$(date -d "-$(date +%d) days" +%Y-%m-%d)
filter_json='{"Dimensions": {"Key": "RECORD_TYPE", "Values": ["Marketplace"]}}'
filter_file=$(mktemp)
echo "$filter_json" > "$filter_file"
result=$(aws ce get-cost-and-usage --time-period Start=$start_date,End=$end_date \
                                   --granularity MONTHLY \
                                   --metrics "UnblendedCost" \
                                   --filter file://$filter_file \
                                   --output json)
rm "$filter_file"
if echo "$result" | jq -e '.ResultsByTime[].Groups[] | select(.Metrics.UnblendedCost.Amount | tonumber > 0)' &> /dev/null; then
    echo "Active AWS Marketplace listing(s) found."
else
    echo "No marketplace listing found."
fi

# 10. Check for AWS credits

# 11. Check for cost allocation tags
echo "Checking for cost allocation tags:"
cost_allocation_tags=$(aws ce list-cost-allocation-tags --query 'CostAllocationTags[*].Key' --output json)
if [ -z "$cost_allocation_tags" ] || [ "$cost_allocation_tags" == "[]" ]; then
    echo "Cost allocation tags are not enabled or no tags are set."
else
    echo "Cost allocation tags are enabled."
fi

echo "Information gathering complete."


