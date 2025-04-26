resource "aws_launch_template" "web_app_template" {
  name          = "web-app-template-${var.unique_suffix}"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    LOG_FILE="/var/log/user_data.log"
    echo "Starting user data script at $(date)" >> $LOG_FILE

    # Update packages and install Python3 and Boto3
    echo "Updating system packages..." >> $LOG_FILE
    sudo apt-get update >> $LOG_FILE 2>&1

    echo "Installing Python3 and pip..." >> $LOG_FILE
    sudo apt-get install -y python3 python3-pip >> $LOG_FILE 2>&1

    echo "Installing Boto3..." >> $LOG_FILE
    sudo pip3 install --break-system-packages boto3 >> $LOG_FILE 2>&1

    # Fetch RDS Credentials from Secrets Manager using Boto3
    echo "Fetching secrets from AWS Secrets Manager..." >> $LOG_FILE
    python3 <<-EOF2 >> $LOG_FILE 2>&1
    import boto3
    import json

    try:
        # Create a Secrets Manager client
        client = boto3.client('secretsmanager', region_name="${var.region}")

        # Fetch RDS credentials
        secret_name = "${var.db_key}"
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        RDS_USERNAME = secret['username']
        RDS_PASSWORD = secret['password']

        # Fetch Email Credentials
        secret_name = "${var.sendgrid_key}"
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        SENDGRID_API_KEY = secret['api_key']

        # Set environment variables
        with open("/opt/myapp/env_vars.sh", "w") as env_file:
            env_file.write(f"export RDS_USERNAME={RDS_USERNAME}\n")
            env_file.write(f"export RDS_PASSWORD={RDS_PASSWORD}\n")
            env_file.write(f"export SENDGRID_API_KEY={SENDGRID_API_KEY}\n")
            env_file.write(f"export RDS_ENDPOINT=${var.rds_endpoint}\n")
            env_file.write(f"export BUCKET_NAME=${var.bucket_name}\n")
            env_file.write(f"export AWS_REGION=${var.region}\n")
            env_file.write(f"export SENDGRID_FROM_EMAIL=${var.sendgrid_from_email}\n")
            env_file.write(f"export SNS_TOPIC_NAME=${var.topic_name}\n")
    except Exception as e:
        print(f"Error fetching secrets: {e}")
        exit(1)
    EOF2

    echo "Setting environment variables..." >> $LOG_FILE
    source /opt/myapp/env_vars.sh >> $LOG_FILE 2>&1

    # Install MySQL client
    echo "Installing MySQL client..." >> $LOG_FILE
    if ! command -v mysql &> /dev/null; then
        sudo apt-get install -y mysql-client >> $LOG_FILE 2>&1
    fi

    # Create the .env file
    echo "Creating the .env file..." >> $LOG_FILE
    {
        echo "DB_URL=jdbc:mysql://$RDS_ENDPOINT/csye6225?serverTimezone=UTC"
        echo "DB_USERNAME=$RDS_USERNAME"
        echo "DB_PASSWORD=$RDS_PASSWORD"
        echo "AWS_BUCKET_NAME=$BUCKET_NAME"
        echo "AWS_REGION=$AWS_REGION"
        echo "SENDGRID_API_KEY=$SENDGRID_API_KEY"
        echo "SENDGRID_FROM_EMAIL=$SENDGRID_FROM_EMAIL"
        echo "SNS_TOPIC_NAME=$SNS_TOPIC_NAME"
        echo "RDS_HOST=$(echo $RDS_ENDPOINT | sed 's/:3306//')"
    } > /opt/myapp/.env

    # Ensure ownership of the .env file
    echo "Changing ownership of .env file..." >> $LOG_FILE
    sudo chown csye6225:csye6225 /opt/myapp/.env >> $LOG_FILE 2>&1

    # Reload systemd
    echo "Reloading systemd..." >> $LOG_FILE
    sudo systemctl daemon-reload >> $LOG_FILE 2>&1

    # Enable and start CloudWatch agent
    echo "Enabling and starting CloudWatch agent..." >> $LOG_FILE
    sudo systemctl enable amazon-cloudwatch-agent >> $LOG_FILE 2>&1
    sudo systemctl start amazon-cloudwatch-agent >> $LOG_FILE 2>&1

    # Enable and start the application service
    echo "Enabling and starting application service..." >> $LOG_FILE
    sudo systemctl enable myapp.service >> $LOG_FILE 2>&1
    sudo systemctl start myapp.service >> $LOG_FILE 2>&1

    echo "User data script completed at $(date)" >> $LOG_FILE
  EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_id
    security_groups             = var.security_group_ids
  }
}
