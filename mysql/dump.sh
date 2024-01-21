#!/bin/bash
# MySQL backup script
# Copyright (c) 2024 Paul The Clown
# ---------------------------------------------------------------------

### Config area
CONFIG_FILE=~/.config/shell-tools/mysql/config

### Import colors ###
source ~/.config/shell-tools/color.config


######################################
### DO NOT MAKE MODIFICATION BELOW ###
######################################

if [ ! -f "${CONFIG_FILE}" ]; then
  ### No Config Found
  echo "Config not cound. Creating ${CONFIG_FILE}"

  ### Create Config File
  echo '######' > ${CONFIG_FILE}
  echo '# mysql dumper config' >> ${CONFIG_FILE}
  echo '# Place this file into folder ~/.config/shell-tools/mysql/' >> ${CONFIG_FILE}
  echo '# If you require sudo to dump MySQL tables, place this file in root/.config/shell-tools/mysql/ folder' >> ${CONFIG_FILE}
  echo '#' >> ${CONFIG_FILE}
  echo '' >> ${CONFIG_FILE}
  echo '### Storage Folder ###' >> ${CONFIG_FILE}
  echo 'BACKUP=.' >> ${CONFIG_FILE}
  echo '' >> ${CONFIG_FILE}
  echo '### MySQL Setup ###' >> ${CONFIG_FILE}
  echo 'MUSER="root"' >> ${CONFIG_FILE}
  echo 'MPASS=""' >> ${CONFIG_FILE}
  echo 'MHOST="localhost"' >> ${CONFIG_FILE}
  echo '' >> ${CONFIG_FILE}
  echo '### Database to Dump ###' >> ${CONFIG_FILE}
  echo 'DBS="medizinfuchs"' >> ${CONFIG_FILE}
  echo '' >> ${CONFIG_FILE}
  echo '### Skip tables when exporting ###' >> ${CONFIG_FILE}
  echo 'SKIPEXPORT="user shop_data"' >> ${CONFIG_FILE}
  echo '' >> ${CONFIG_FILE}
  echo '### Skip tables when importing ###' >> ${CONFIG_FILE}
  echo 'SKIPIMPORT="test shop_data"' >> ${CONFIG_FILE}
  echo '' >> ${CONFIG_FILE}
  exit
else
  # config file found

  source $CONFIG_FILE
fi


### check if database is set
if [ ! -n "${DBS}" ]; then
  echo "No Databases given"
  exit
fi

### Binaries ###
#TAR="$(which tar)"
#GZIP="$(which gzip)"
#MYSQL="$(which mysql)"
#MYSQLDUMP="$(which mysqldump)"

### Today + hour in 24h format ###
NOW=$(date '+%Y%m%d-%H%M%S')

### Create date based backup folder ###
mkdir $BACKUP/$NOW

for db in $DBS; do

  ### Create dir for each databases, backup tables in individual files ###
  for i in $(echo "show tables" | MYSQL_PWD=$MPASS $MYSQL -u $MUSER -h $MHOST $db | grep -v Tables_in_); do
    doSkip=0
    for table in ${SKIPEXPORT[@]}; do
      if [[ ${table} == $i ]]; then
        echo -e $RED"Skip"$NC"....: $table"
        doSkip=1
      fi
    done

    if [ ${doSkip} == 1 ]; then
      continue
    fi

    echo -e $GREEN"Dumping"$NC".: $i"

    FILE=$BACKUP/$NOW/$i.sql.gz
    MYSQL_PWD=$MPASS $MYSQLDUMP --add-drop-table --allow-keywords -q -c -u $MUSER -h $MHOST $db $i | $GZIP -9 >$FILE
  done
done

### Compress all tables in one nice file to download ###
ARCHIVE=$BACKUP/$NOW.tgz
ARCHIVED=$BACKUP/$NOW

$TAR -cvf $ARCHIVE $ARCHIVED > /dev/null 2>&1

### Delete the backup dir and keep archive ###
rm -rf $ARCHIVED

echo -e $GREEN"Done"$NC
