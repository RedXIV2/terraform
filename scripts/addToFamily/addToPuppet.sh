if [ -z "$1" ]
  then
    echo "$(date) No argument supplied" >> /myLogs.txt
    exit 1
fi

echo "$(date) installing AWSCLI" >> /myLogs.txt
sudo apt update
sudo apt install -y awscli

echo "$(date) checking AWSCLI" >> /myLogs.txt
until [ -x "$(command -v aws)" ]
do
  echo 'Error: aws is not installed.' >&2
  sudo apt install -y awscli
done

echo "$(date) Searching for client details ..." >> /myLogs.txt

CONFIG_DNS="$(sudo aws ec2 describe-instances --filters "Name=private-ip-address,Values=$1" \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PrivateDnsName]' \
   --region eu-west-1 --output text)"

echo "$(date) Private DNS is ${CONFIG_DNS}" >> /myLogs.txt

PUBLIC_DNS="$(sudo aws ec2 describe-instances --filters "Name=private-ip-address,Values=$1" \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PublicDnsName]' \
   --region eu-west-1 --output text)"

echo "$(date) Public DNS is ${PUBLIC_DNS}" >> /myLogs.txt

NODE_ID="$(sudo aws ec2 describe-instances --filters "Name=private-ip-address,Values=$1" \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].Tags[*].Value' \
   --region eu-west-1 --output text)"

NODE_ID_NUMBER=$(echo ${NODE_ID: -1} )

echo "$(date) Node Identifier is ${NODE_ID_NUMBER}" >> /myLogs.txt
if [ -z "$3" ]
  then
  HOST_ENTRY="$1 puppet-agent-$NODE_ID_NUMBER $CONFIG_DNS $PUBLIC_DNS puppet-agent-$NODE_ID_NUMBER.eu-west-1.compute.internal" 

  echo "$(date) Adding $HOST_ENTRY to hosts file" >> /myLogs.txt
  sudo echo $HOST_ENTRY >> /etc/hosts
  else
  HOST_ENTRY="$1 thesisnode.northeurope.cloudapp.azure.com"
  echo "$(date) Adding $HOST_ENTRY to hosts file" >> /myLogs.txt
  sudo echo $HOST_ENTRY >> /etc/hosts
fi

sudo service puppetmaster restart

echo "$(date) running sudo bash /terraform/scripts/runTests.sh $2 Puppet" >> /myLogs.txt
sudo bash /terraform/scripts/runTests.sh $2 Puppet $1

