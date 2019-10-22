if [ -z "$1" ]
  then
    echo "$(date) No argument supplied" >> /myLogs.txt
    exit 1
fi

if grep -q "$1" /etc/ansible/hosts; then
    echo "$(date) $1 already in file" >> /myLogs.txt
    exit 0
fi

if grep -q "\[servers\]" /etc/ansible/hosts; then
    echo "$(date) found and added $1" >> /myLogs.txt
    echo "$1" >> /etc/ansible/hosts
else
    echo "$(date) not found and added $1" >> /myLogs.txt
    echo [servers] >> /etc/ansible/hosts
    echo "$1" >> /etc/ansible/hosts
fi

echo "$(date) running sudo bash /terraform/scripts/runTests.sh $2 Ansible" >> /myLogs.txt
sudo bash /terraform/scripts/runTests.sh $2 Ansible $1