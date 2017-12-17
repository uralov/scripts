#!/bin/sh
db_name=""
db_user=""
db_pass=""

for n in `mysql $db_name -u$db_user -p$db_pass -B -N -e "show tables;"`;
    do mysql $db_name -u$db_user -p$db_pass -B -N -e "OPTIMIZE TABLE $n;";
done
