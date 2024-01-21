#!/bin/bash
# MySQL import script
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
  echo "Configuration not found. Please use mf-dump.sh to create a valid configuration."
  exit
else
  # config file found
  source $CONFIG_FILE
fi

### Define folder ###
if [ ${#1} -ge 4 ] && [ -n "${1::-4}" ]; then
    FOLDER2EXTRACT=${1::-4}
else
    echo -e $RED"No Database.tgz selected"$NC
    echo -e $GREEN"Example usage: $YELLOW $0$CYAN Database.tgz$NC"
    exit
fi

### check if database is set
if [ ! -n "${DBS}" ]; then
  echo "No Databases selected. (No config?)"
  exit
fi

### Check if zcat is available
if ! command -v zcat &> /dev/null; then
    echo -e $RED"zcat is not available. Please install it or use an alternative."$NC
    exit 1
fi

### Create date based backup folder ###
if [ ! -d $FOLDER2EXTRACT ]; then
  mkdir $FOLDER2EXTRACT
fi

### Extract dump ###
echo -e $CYAN"Extracting$NC: $1"
tar xvf $1 -C $FOLDER2EXTRACT > /dev/null 2>&1
cd $FOLDER2EXTRACT/$FOLDER2EXTRACT

### File processing ###
file_array=("."/*.sql.gz)
if [ ${#file_array[@]} -eq 0 ]; then
    echo -e $RED"No .sql.gz-Files found."$NC
    exit
fi

### Process ###
for file in "${file_array[@]}"; do
    # DEFINE TABLE NAME
    tableName="${file#./}"   # REMOVE "./"
    tableName="${tableName%.sql.gz}"  # REMOVE ".sql.gz"

    doSkip=0
    for table in ${SKIPIMPORT[@]}; do
      if [[ ${table} == $tableName ]]; then
        echo -e $RED"Skip"$NC"......: $table"
        doSkip=1
      fi
    done

    if [ ${doSkip} == 1 ]; then
      continue
    fi

    echo -e $GREEN"Importing"$NC".: $tableName"

    zcat "$file" | MYSQL_PWD=$MPASS mysql -u $MUSER -h $MHOST "$DBS"
done

cd ../..
rm -rf $FOLDER2EXTRACT 2/dev/null

echo -e $GREEN"Done"$NC
