---
title: Opening multiple DB tunnels with AWS SSM
date: 2024-06-26
extra:
  kind: note
---

To open a tunneled connection to an AWS managed database, such as RDS or DocumentDB, the commonly recommended way is to use a bastion host and `aws ssm start-session`. The bastion host is an EC2 instance that is in the same VPC as your database. The AWS CLI command allows you to connect to SSM-enabled EC2 instances from your development machine using IAM authorization, without having to manage SSH keys.

The script below connects to the specified PostgreSQL RDS and DocumentDB instances using a bastion host. Both databases will be accessible on a `localhost` port. Modify as necessary.

```bash
#!/bin/bash

# Configure to match your environment
BASTION_NAME="<YOUR_BASTION_INSTANCE_NAME>"
DOCDB_CLUSTER_NAME="<YOUR_DOCDB_CLUSTER_NAME>"
PG_CLUSTER_NAME="<YOUR_RDS_CLUSTER_NAME>"
DOCDB_PORT="27017"
PG_PORT="5432"

# Fail on errors, do not allow use of unset variables
set -eu

# Colors for nicer output
BB="\\033[34m"
RST="\\033[0m"

# Fetch the endpoints URIs and bastion instance ID
DOCDB_ENDPOINT=$(aws docdb describe-db-clusters --db-cluster-identifier "${DOCDB_CLUSTER_NAME}" --query "DBClusters[0].Endpoint" --output text)
PG_ENDPOINT=$(aws rds describe-db-clusters --db-cluster-identifier "${PG_CLUSTER_NAME}" --query "DBClusters[0].Endpoint" --output text)
BASTION_INSTANCE=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=${BASTION_NAME}" --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[]" --output text)

echo "DocumentDB endpoint: ${DOCDB_ENDPOINT}"
echo "PostgreSQL endpoint: ${PG_ENDPOINT}"
echo "Bastion host instance ID: ${BASTION_INSTANCE}"
echo ""

echo -e "${BB}Starting SSM sessions with DocumentDB and PostgreSQL port forwarding in localhost in this terminal...${RST}"

# DocumentDB port forwarding
aws ssm start-session \
  --target "${BASTION_INSTANCE}" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"portNumber":["'${DOCDB_PORT}'"],"localPortNumber":["'${DOCDB_PORT}'"],"host":["'"${DOCDB_ENDPOINT}"'"]}' &
PID1=$!

# PostgreSQL port forwarding
aws ssm start-session \
  --target "${BASTION_INSTANCE}" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"portNumber":["'${PG_PORT}'"],"localPortNumber":["'${PG_PORT}'"],"host":["'"${PG_ENDPOINT}"'"]}' &
PID2=$!

cleanup() {
  echo "Caught CTRL-C, stopping both tunnels..."
  kill $PID1 $PID2
  exit
}

# Catch the interrupt signal (CTRL-C)
trap cleanup INT

# Wait for both processes to exit
wait $PID1
wait $PID2
```
