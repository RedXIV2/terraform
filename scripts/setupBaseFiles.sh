# Create the log file for all future system logging
touch /myLogs.txt
chmod 777 /myLogs.txt
echo "$(date) Log File created and permissions set" >> myLogs.txt

# copy addTo Family of scripts to / directory
cp /terraform/scripts/addToFamily/addTo* /
chmod 700 /addTo*
echo "$(date) AddToFamily scripts copied and permissions set" >> myLogs.txt

# change key permissions
chmod 600 /tmp/awsthesis.pem
echo "$(date) key permissions updated"

if [ "$1" == "ansible" ]
then
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible >> /output.log 2>&1
sudo sed -i '/callback_whitelist/c\callback_whitelist = profile_tasks' /etc/ansible/ansible.cfg
sudo sed -i '/host_key_checking/c\host_key_checking = False' /etc/ansible/ansible.cfg
sudo sed -i '/#remote_user/c\remote_user = ubuntu' /etc/ansible/ansible.cfg
sudo sed -i '/#private_key_file/c\private_key_file = /tmp/awsthesis.pem' /etc/ansible/ansible.cfg
fi

if [ "$1" == "salt" ]
then
wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/saltstack.list
sudo echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" >> /etc/apt/sources.list.d/saltstack.list

sudo apt-get install -y salt-master
sudo apt-get install -y salt-minion
sudo apt-get install -y salt-ssh
sudo apt-get install -y salt-syndic
sudo apt-get install -y salt-cloud
sudo apt-get install -y salt-api

sudo echo "auto_accept: True" >> /etc/salt/master
sudo echo "file_roots: " >> /etc/salt/master
sudo echo "  base: " >> /etc/salt/master
sudo echo "    - /srv/salt " >> /etc/salt/master

sudo service salt-master start

sudo cp /terraform/tests/Salt/top.sls /srv/salt/
fi
