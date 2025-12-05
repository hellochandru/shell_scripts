!/bin/bash
exec > /var/log/jenkins_install.log 2>&1
# Define variables
#EC2_INSTANCE_TYPE="t2.medium"
# Note: Launching the EC2 machine via a *single* shell script requires complex AWS CLI commands
# which also need appropriate IAM permissions and key-pair management.
# This script assumes you are running it *inside* the already launched EC2 instance as a standard user with sudo privileges.

echo "--- Step 0: Pre-requisite checks (Assumes you are on RHEL/CentOS-based EC2 machine with sudo access) ---"
# Verify user privileges (optional)
if [[ $(id -u) -eq 0 ]]; then
    echo "Warning: Script is running as root. This might not follow best practices for initial setup steps."
fi

echo "--- Step 1: Switch to root user context for seamless execution of subsequent commands ---"
# We switch context and re-execute the rest of the script if not already root
if [[ $(id -u) -ne 0 ]]; then
    echo "Switching to root user and re-running the script..."
    exec sudo su - "$0" "$@"
    # The 'exec' command replaces the current shell process with a new one as root.
    # The script continues from the top in the new shell, where the 'if' condition will now be false.
fi
echo "Now running as root user (UID 0)."


echo "--- Step 2: Install required utilities and Jenkins (Stable Release) ---"

echo "Installing wget and tree utilities..."
yum install wget tree -y

echo "Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "Upgrading yum packages..."
yum upgrade -y

echo "Installing required dependencies (Java 21 OpenJDK and fontconfig)..."
# Note: Jenkins officially supports Java 11/17 for current stable releases, Java 21 might be bleeding edge/experimental at times.
# Sticking to the user's requested Java 21 package name 'java-21-openjdk'
yum install fontconfig java-21-openjdk -y

echo "Installing Jenkins..."
yum install jenkins -y
systemctl daemon-reload


echo "--- Step 3: Enable Jenkins service to start automatically on boot ---"
systemctl enable jenkins


echo "--- Step 4: Start Jenkins service and check status ---"
echo "Starting Jenkins service..."
systemctl start jenkins

echo "Checking Jenkins service status..."
systemctl status jenkins
# The status output will be printed to the console, confirming if it's running.


echo "--- Setup Complete ---"
echo "Jenkins has been installed, enabled, and started."
echo "You can check the initial admin password using the following command:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"



