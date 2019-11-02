fileName=${1}users.yml
folderCounter=${1}
fileCounter=${2}

echo "---" >> ${fileName}
echo "- hosts: all" >> ${fileName}
echo "  tasks:" >> ${fileName}
echo " " >> ${fileName}
echo "    - name: Create the test group" >> ${fileName}
echo "      group: name=test" >> ${fileName}
echo "      become: true" >> ${fileName}
echo " " >> ${fileName}

#for i in {1..${counter}}
for ((i=1; i <=folderCounter; i++));
do
echo "    - name: Creates directory test$i" >> ${fileName}
echo "      file:" >> ${fileName}
echo "        path: /tmp/test$i"  >> ${fileName}
echo "        state: directory"  >> ${fileName}
echo "        group: ubuntu"  >> ${fileName}
echo "        owner: ubuntu"  >> ${fileName}
echo "        mode: 0775" >> ${fileName}
echo "      become: true" >> ${fileName}
echo " " >> ${fileName}

for ((j=1; j <=fileCounter; j++));
do
echo "    - name: Creates file test$j in directory$i" >> ${fileName}
echo "      file:" >> ${fileName}
echo "        path: /tmp/test$i/test$j.txt"  >> ${fileName}
echo "        state: touch"  >> ${fileName}
echo "        group: ubuntu"  >> ${fileName}
echo "        owner: ubuntu"  >> ${fileName}
echo "        mode: 0775" >> ${fileName}
echo "      become: true" >> ${fileName}
echo " " >> ${fileName}

done
done


