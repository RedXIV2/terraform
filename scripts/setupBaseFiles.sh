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

if [ "$s1" == "ansible" ]
then
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible >> /output.log 2>&1
sudo sed -i '/callback_whitelist/c\callback_whitelist = profile_tasks' /etc/ansible/ansible.cfg
sudo sed -i '/host_key_checking/c\host_key_checking = False' /etc/ansible/ansible.cfg
sudo sed -i '/#remote_user/c\remote_user = ubuntu' /etc/ansible/ansible.cfg
sudo sed -i '/#private_key_file/c\private_key_file = /tmp/awsthesis.pem' /etc/ansible/ansible.cfg
fi

