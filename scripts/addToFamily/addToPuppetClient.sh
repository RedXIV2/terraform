if [ -z "$1" ]
  then
    echo "$(date) No argument supplied" >> /myLogs.txt
    exit 1
fi




echo "$(date) installing AWSCLI" >> /myLogs.txt
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y awscli

echo "$(date) checking AWSCLI" >> /myLogs.txt
until [ -x "$(command -v aws)" ]
do
  echo 'Error: aws is not installed.' >&2
  sudo apt install -y awscli
done

NODE_ID=$(sudo aws ec2 describe-instances --filters "Name=private-ip-address,Values=$1" \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].Tags[*].Value' \
   --region eu-west-1 --output text)

NODE_ID_NUMBER=$(echo ${NODE_ID: -1} )

sudo hostnamectl set-hostname puppet-agent-"${NODE_ID_NUMBER}"


echo "$(date) Searching for config master ..." >> /myLogs.txt

CONFIG_DNS=$(sudo aws ec2 describe-instances --filters 'Name=tag:Name,Values=ConfigMaster' \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PrivateDnsName]' \
   --region eu-west-1 --output text)

echo "$(date) Private DNS is ${CONFIG_DNS}" >> /myLogs.txt

PUBLIC_DNS=$(sudo aws ec2 describe-instances --filters 'Name=tag:Name,Values=ConfigMaster' \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PublicDnsName]' \
   --region eu-west-1 --output text)

echo "$(date) Config DNS is ${PUBLIC_DNS}" >> /myLogs.txt

PRIVATE_IP=$(sudo aws ec2 describe-instances --filters 'Name=tag:Name,Values=ConfigMaster' \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PrivateIpAddress]' \
   --region eu-west-1 --output text)

echo "$(date) Private IP is ${PRIVATE_IP}" >> /myLogs.txt

HOST_ENTRY="$PRIVATE_IP puppet-master $CONFIG_DNS $PUBLIC_DNS puppet-master.eu-west-1.compute.internal" 

echo "$(date) Adding $HOST_ENTRY to hosts file" >> /myLogs.txt
sudo echo $HOST_ENTRY >> /etc/hosts

sudo apt install puppet -y

echo "$(date) Updating puppet.conf" >> /myLogs.txt
sudo sed -i '/postrun_command=\/etc\/puppet\/etckeeper-commit-post/a server = puppet-master.eu-west-1.compute.internal' /etc/puppet/puppet.conf

sudo puppet agent --no-daemonize --onetime --verbose
sudo puppet agent --enable
sudo puppet agent --server puppet-master.eu-west-1.compute.internal
sudo puppet agent --test
