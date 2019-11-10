fileName=${1}files.pp
folderCounter=${1}
fileCounter=${2}

echo "class directories {" >> ${fileName}
echo " " >> ${fileName}

#for i in {1..${counter}}
for ((i=1; i <=folderCounter; i++));
do
echo "file { '/tmp/test$i':" >> ${fileName}
echo "  ensure => 'directory'," >> ${fileName}
echo "}"  >> ${fileName}
echo " " >> ${fileName}

for ((j=1; j <=fileCounter; j++));
do
echo "file { '/tmp/test$i/test$j.txt':" >> ${fileName}
echo "  ensure => 'present'," >> ${fileName}
echo "}"  >> ${fileName}
echo " " >> ${fileName}


done
done
echo "}" >> ${fileName}
