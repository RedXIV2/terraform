fileName=${1}users.yml
counter=${1}

echo "---" >> ${fileName}
echo "- hosts: servers" >> ${fileName}
echo "  tasks:" >> ${fileName}
echo " " >> ${fileName}
echo "    - name: Create the test group" >> ${fileName}
echo "      group: name=test" >> ${fileName}
echo "      become: true" >> ${fileName}
echo " " >> ${fileName}

#for i in {1..${counter}}
for ((i=1; i <=counter; i++));
do
echo "    - name: Create test User$i" >> ${fileName}
echo "      user:" >> ${fileName}
echo "        name: user$i"  >> ${fileName}
echo "        shell: /bin/bash"  >> ${fileName}
echo "        group: test"  >> ${fileName}
echo "        append: yes"  >> ${fileName}
echo "        comment: \"thesis user\"" >> ${fileName}
echo "        state: present" >> ${fileName}
echo "      become: true" >> ${fileName}
echo " " >> ${fileName}
done

