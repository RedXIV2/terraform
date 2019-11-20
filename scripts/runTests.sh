if [ -z "$1" ]
  then
    echo "$(date) No testcase identifier supplied" >> /myLogs-$3.txt
    exit 1
fi

if [ -z "$2" ]
  then
    echo "$(date) No testcase technology supplied" >> /myLogs-$3.txt
    exit 1
fi

if [ -z "$3" ]
  then
    echo "$(date) No IP address supplied" >> /myLogs-$3.txt
    exit 1
fi

echo "$(date) ***Running Test***" >> /myLogs-$3.txt

path_to_test=/terraform/tests/$2/
test_case_to_run=$1
full_test="$(ls ${path_to_test}${test_case_to_run}*/* )"

echo "$(date) Executing: ${full_test}" >> /myLogs-$3.txt

#Ansible specific test runner
if [ "$2" == "Ansible" ]
then
sudo -u ubuntu ansible-playbook -i $3, ${full_test} >> /myLogs-$3.txt 2>&1
fi

#Salt specific test runner
if [ "$2" == "Salt" ]
then

state_to_apply="$(echo ${full_test} | sed 's|.*/||' | sed 's/.\{4\}$//')"

until [ -x "$(command -v salt-call)" ]
do
  echo 'Error: salt is not installed.' >> /myLogs-$3.txt
done


sudo salt-call state.sls ${state_to_apply} >> /myLogs-$3.txt 2>&1

fi

echo "$(date) ***Finished Test***" >> /myLogs-$3.txt

echo "$(date) ***Uploading Test Results***" >> /myLogs-$3.txt
echo "$(date) Executing: aws s3 mv /myLogs-$3.txt s3://dhill-config-management-tests/debug/${2}/myLogs-$(date).txt >> awsCopy.log 2>&1" >> /myLogs-$3.txt

aws s3 mv /myLogs-$3.txt s3://dhill-config-management-tests/debug/"${2}"/myLogs-$3-"$(date)".txt >> awsCopy.log 2>&1

echo "$(date) ***Finished Upload***" >> /myLogs-$3.txt

