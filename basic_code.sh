#!/bin/bash
#initializing variables
bit=32
bitv="x86_64"
source=".rpm"
model="Ubuntu"
extra="jdk"

#checking for system version
uname -m > vers.txt
while read -r li; do
if [ $bitv = $li ]
then 
bit=64
break;
else
break;
fi
done < vers.txt

#checking if it is ubuntu/centos
cat /etc/issue > vers.txt
while read -r li; do
if echo "$li" | grep -q "$model";then
echo "Updating this Ubuntu Machine";
sudo apt-get update
break;
else 
echo "Updating this CentOs Machine";
model="Centos"
sudo yum update
break;
fi
done < vers.txt

#reading given text file for just length
lineno=0
while read -r line; do
lineno=`expr $lineno + 1`
done < basic.txt

#reading given text file with nth line
i=0 
while [ $i -lt $lineno ]; do
i=`expr $i + 1`
head -$i basic.txt | tail -1 > vers.txt
read -r line < vers.txt
line="$line-linux"
if test $bit -eq 32
then 
line="$line-x86"
else
line="$line-x64"
fi 

if [ $model = "Ubuntu" ]
then
lback=$line
line="$line-u"
else
lback=$line
line="$line-c"
fi

#Downloading and
#Installing
if [ $model = "Ubuntu" ]
then
#checking for wget installation and proxy settings
sudo apt-get install wget
export http_proxy=""
wget -r --no-parent 10.4.15.172/$line/
cd 10.4.15.172/$line/
dpkg -i *.deb
success=`echo $?`
cd -
else
#checking for wget installation and proxy settings
sudo yum install wget
export http_proxy=""
wget -r --no-parent 10.4.15.172/$line/
cd 10.4.15.172/$line/
echo "HERE !---------------------------------------------------------------------------"
echo pwd
yum install *.rpm
echo "HERE @---------------------------------------------------------------------------"
success=`echo $?`
cd -
echo pwd
fi 
#DISPLAYING SUCCESS MSG
#echo "\nSuccess = $success"

if test $success -eq 0 
then
#now to set path...
if echo "$line" | grep -q "$extra";then
echo "JAVA_HOME=/usr/lib/jvm/$lback" >> "/etc/profile"
echo "PATH=$PATH:$HOME/bin:$JAVA_HOME/bin" >> "/etc/profile"
echo "export JAVA_HOME" >> "/etc/profile" 
echo "export JRE_HOME" >> "/etc/profile"
echo "export PATH" >> "/etc/profile" 
fi
else 
echo "------------------------------------------INSTALLING DEPENDENCIES---------------------------------"

if [ $model = "Ubuntu" ]
then
export http_proxy="http://proxy.iiit.ac.in:8080"
sudo apt-get -f install
else
export http_proxy="http://proxy.iiit.ac.in:8080"
sudo yum update
#sudo yum localinstall $line
fi

echo "------------------------------------------INSTALLED DEPENDENCIES-----------------------------------"

fi

done

#having old proxy
export http_proxy="http://proxy.iiit.ac.in:8080"

pwd > vers.txt
read -r li < vers.txt
rm $li/vers.txt
#rm -R $line


