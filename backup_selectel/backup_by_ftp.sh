#!/bin/sh

process=`ps ax|grep $0|grep -vq grep`
if [ -n "$process" ]; then
	echo "Process $0 already run!"
	echo $process
	exit
fi

server="ftp.selcdn.ru"
container=""
user=""
pass=""
admin_mail=""

host_name=`uname -n`
date=`date +"%F"`
noactual_date=`date --date='3 day ago' +"%F"`
backup_dir=""
result_dir=""
curent_dir=""
part_file_size="512m"


#chmod -R go=rX $backup_dir
# create result_dir
rm -rf $result_dir
if [ ! -d $result_dir ]; then
	mkdir -p $result_dir
fi

# split file by $part_file_size
for full_file_name in `find $backup_dir -type f -mtime 0`; do
	file_name=`echo $full_file_name|awk -F"/" '{print $NF}'`
	ionice -c3 split -a 1 -b $part_file_size $full_file_name $result_dir/$file_name.
done;

# upload file on server
$curent_dir/supload.sh -u $user -k $pass -r -M $container/$date $result_dir/ > /dev/null

# old method put
#for file_name in `find $result_dir -type f -mtime 0|awk -F"/" '{print $NF}'`; do
#	curl --ftp-create-dirs -T $result_dir/$file_name ftp://$user:$pass@$server/$container/$date/
#done;

#check backup
sleep 100
ftp_files=`curl -s -l ftp://$user:$pass@$server/$container/$date/`
local_files=`ls $result_dir`
# get count symbols in $ftp_files and $local_files
ff=${#ftp_files}
lf=${#local_files}
if [ -z "$ftp_files" -o "$ff" != "$lf" ]; then
    echo "Backup error in $server/$container/$date."
    echo "Backup error in $server/$container/$date. ff='$ff' lf='$lf'" | mail -s "$host_name: backup error" $admin_mail
    exit
fi

#delete old backup
for file_name in `curl -s -l ftp://$user:$pass@$server/$container/$noactual_date/`; do
	curl -s --quote "DELE $container/$noactual_date/$file_name" ftp://$user:$pass@$server/ > /dev/null
done;
curl -s --quote "RMD $container/$noactual_date" ftp://$user:$pass@$server/ > /dev/null
