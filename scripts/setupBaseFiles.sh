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