#!/bin/sh
user=""
pass=""
date=`date +"%F"`
backup_dir=""

mkdir -p $backup_dir/$date

for dbname in `echo show databases | mysql -u$user -p$pass`; do
	echo "Dump $dbname..."
	mysqldump -u$user -p$pass $dbname | gzip > $backup_dir/$date/$dbname.gz
done;

# Удаляем файлы старше 30 дней
find $backup_dir -atime +30 | xargs rm -rf
