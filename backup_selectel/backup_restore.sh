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

actual_date=`date +"%F"`
#actual_date=`date --date='3 day ago' +"%F"`
result_dir=""
restore_dir=""


# create result_dir
rm -rf $result_dir
if [ ! -d $result_dir ]; then
        mkdir -p $result_dir
fi
if [ ! -d $restore_dir ]; then
        mkdir -p $restore_dir
fi

# download backup
for file_name in `curl -l ftp://$user:$pass@$server/$container/$actual_date/`; do
        curl ftp://$user:$pass@$server/$container/$actual_date/$file_name -o $result_dir/$file_name
done;

# get restore file names
for file_name in `find $result_dir -type f -mtime 0|awk -F"/" '{print $NF}'`; do
        echo ${file_name%???} >> file_names.txt
done;
# restore files
for file_name in `sort -u file_names.txt`; do
        cat $result_dir/$file_name* > $restore_dir/${file_name}
done;
rm -f file_names.txt
