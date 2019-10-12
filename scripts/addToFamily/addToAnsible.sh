if [ -z "$1" ]
  then
    echo "No argument supplied" >> /myLogs.txt
    exit 1
fi

if grep -q "$1" /etc/ansible/hosts; then
    echo "$1 already in file" >> /myLogs.txt
    exit 0
fi

if grep -q "\[servers\]" /etc/ansible/hosts; then
    echo "found and added $1" >> /myLogs.txt
    echo "$1" >> /etc/ansible/hosts
else
    echo "not found and added $1" >> /myLogs.txt
    echo [servers] >> /etc/ansible/hosts
    echo "$1" >> /etc/ansible/hosts
fi
