#!/bin/sh
# перед запуском необходимо установить pip install awscli
# и настроить asw по инструкции http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html

user="root"
pass=""

date=`date +"%F"`
noactual_date=`date --date='3 day ago' +"%F"`
backup_dir="" # промежуточная директория
sync_dir="s3://bucket/dir" # директория назначения
aws="/usr/local/bin/aws"


mkdir -p $backup_dir/$date

for dbname in `echo show databases | mysql -N -u$user -p$pass`; do
    mysqldump --lock-tables=false --single-transaction -u$user -p$pass $dbname | gzip > $backup_dir/$date/$dbname.gz
done;

# sync backup
$aws s3 sync --only-show-errors $backup_dir/$date $sync_dir/$date

# check backup
remote_files=`$aws s3 ls $sync_dir/$date/ | awk '{print $3 $4}'`
local_files=`ls -l $backup_dir/$date/ | sed /^total/d | awk '{print $5 $9}'`
if [ "$remote_files" != "$local_files" ]; then
    echo "Backup error $0"
    echo "remote files: $remote_files"
    echo "local files: $local_files"
fi

# remove local files
rm -rf $backup_dir/$date

# delete old backup
$aws s3 rm --only-show-errors --recursive $sync_dir/$noactual_date
