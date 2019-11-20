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


echo "$(date) Searching for config master ..." >> /myLogs.txt

CONFIG_DNS=$(sudo aws ec2 describe-instances --filters 'Name=tag:Name,Values=ConfigMaster' \
  'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PrivateDnsName]' \
   --region eu-west-1 --output text)

echo "$(date) Config DNS is ${CONFIG_DNS}" >> /myLogs.txt

echo "$(date) Getting bootstrap script" >> /myLogs.txt
sudo curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com

echo "$(date) bootstrap needs to be executable" >> /myLogs.txt
sudo chmod +x bootstrap-salt.sh

echo "$(date) bootstrapping salt minion..." >> /myLogs.txt
sudo sh bootstrap-salt.sh -A "${CONFIG_DNS}"

echo "$(date) Bootstrapping complete" >> /myLogs.txt


echo "$(date) running sudo bash /terraform/scripts/runTests.sh $2 Salt" >> /myLogs.txt
sudo bash /terraform/scripts/runTests.sh $2 Salt $1 
