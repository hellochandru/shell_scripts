# This script automates the installation of Java OpenJDK and Apache Maven on a Linux system.
# 
# Steps performed by the script:
# 1. Switches to the root user to ensure that the script has the necessary permissions to install packages.
# 2. Updates all installed packages to their latest versions using the `yum` package manager.
# 3. Searches for available versions of OpenJDK and filters the results to show only those containing "OpenJDK".
# 4. Installs the OpenJDK version 21 development package.
# 5. Navigates to the /opt directory, which is a common location for installing third-party software.
# 6. Downloads the Apache Maven binary zip file from the official Apache repository.
# 7. Unzips the downloaded Maven package to extract its contents.
# 8. Opens the user's bash profile file to allow for the addition of environment variables.
# 9. Sets the M2_HOME environment variable to point to the Maven installation directory.
# 10. Updates the system PATH variable to include the Maven binary directory, allowing Maven commands to be run from any location.
# 11. Checks if Maven is installed by running `mvn -version` or `mvn -v`. If not installed, prompts the user to load the updated profile.
# 12. Loads the updated bash profile to apply the new environment variables.
# 13. Finally, checks the Maven version again to confirm that the installation was successful.
!/bin/bash
sudo su - #switch user to root
yum update -y # update all packages
sudo yum search java | grep -i OpenJDK # to search available java versions
sudo yum install java-21-openjdk-devel -y # install java 21
cd /opt/ # navigate to /opt directory
wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.zip # download maven
unzip apache-maven-3.9.11-bin.zip # unzip the downloaded file
vi ~/.bash_profile # open bash profile to set environment variables
export M2_HOME=/opt/apache-maven-3.9.11 # set M2_HOME variable
export PATH=$PATH:$M2_HOME/bin # update PATH variable
mvn -version or mvn -v #----> Not installed , you need to load 
source ~/.bash_profile # load the updated bash profile
mvn -version or mvn -v #---> to check maven version