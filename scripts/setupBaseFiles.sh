# Create the log file for all future system logging
touch /myLogs.txt
chmod 777 /myLogs.txt
echo "$(date) Log File created and permissions set"

# copy addTo Family of scripts to / directory
cp addToFamily/addTo* /
chmod 700 /addTo*
echo "$(date) AddToFamily scripts copied and permissions set"


