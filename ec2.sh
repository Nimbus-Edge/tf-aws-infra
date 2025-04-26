#!/bin/bash

# Install MySQL client
if ! command -v mysql &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y mysql-client
fi

# Check if values are set
if [[ -z "${RDS_ENDPOINT}" || -z "${RDS_USERNAME}" || -z "${RDS_PASSWORD}" ]]; then
    echo "Error: One or more required environment variables are not set. Exiting."
    exit 1
fi

# Create the .env file with the RDS credentials
echo "Creating .env file"
{
    echo "DB_URL=jdbc:mysql://${RDS_ENDPOINT}/csye6225?serverTimezone=UTC"
    echo "DB_USERNAME=${RDS_USERNAME}"
    echo "DB_PASSWORD=${RDS_PASSWORD}"
    echo "AWS_BUCKET_NAME=${BUCKET_NAME}"
    echo "AWS_REGION=${AWS_REGION}"
    echo "SENDGRID_API_KEY"=${SENDGRID_API_KEY}
    echo "SENDGRID_FROM_EMAIL"=${SENDGRID_FROM_EMAIL}
    echo "RDS_HOST=$(echo ${RDS_ENDPOINT} | sed 's/:3306//')"
} > /opt/myapp/.env

# Ensure the ownership of the .env file is correct
if ! sudo chown csye6225:csye6225 /opt/myapp/.env; then
    echo "Failed to change ownership of .env file" && exit 1
fi

# Reload systemd
if ! sudo systemctl daemon-reload; then
    echo "Failed to reload systemd" && exit 1
fi

# Enable and start cloud watch agent
if ! sudo systemctl enable amazon-cloudwatch-agent; then
    echo "Failed to enable cloudwatch agent" && exit 1
fi

if ! sudo systemctl start amazon-cloudwatch-agent; then
    echo "Failed to start cloudwatch agent" && exit 1
fi

# Enable and start the service
if ! sudo systemctl enable myapp.service; then
    echo "Failed to enable myapp.service" && exit 1
fi

if ! sudo systemctl start myapp.service; then
    echo "Failed to start myapp.service" && exit 1
fi