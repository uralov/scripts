#!/bin/sh
date=`date +"%F"`
backup_dir=""

mkdir -p $backup_dir/$date

for dbname in `sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"`; do
    echo "Dump $dbname..."
    sudo -u postgres pg_dump -Fc -x -O $dbname | gzip > $backup_dir/$date/$dbname.sql
done;

# Удаляем файлы старше 30 дней
find $backup_dir -atime +30 | xargs rm -rf
