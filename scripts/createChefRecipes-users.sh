fileName=default.rb
counter=${1}

echo "# Cookbook:: user_creation" >> ${fileName}
echo "# Recipe:: default" >> ${fileName}
echo "#" >> ${fileName}
echo "# Copyright:: 2018, The Authors, All Rights Reserved. " >> ${fileName}
echo " " >> ${fileName}

for ((i=1; i <=counter; i++));
do
echo "user 'testuser$i' do"  >> ${fileName}
echo "  comment 'Chef Test User $i'" >> ${fileName}
echo "  uid '20$i' " >> ${fileName}
echo "  home '/home/testuser$i'" >> ${fileName}
echo "  shell '/bin/bash'" >> ${fileName}
echo "end" >> ${fileName}
echo " " >> ${fileName}
done

