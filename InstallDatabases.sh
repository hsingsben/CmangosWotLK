#!/bin/sh
##############################################################################
# 
#   Simple helper script to insert clean WoTLK-DB
#
##############################################################################

# need to be changed on each official DB/CORE release
FULLDB_FILE="WoTLKDB_1_2_13992.sql"
DB_TITLE="v1.2 'Ymiron'"
NEXT_MILESTONES="0.19 0.20"

#internal use
SCRIPT_FILE="InstallDatabases.sh"
CONFIG_FILE="InstallFullDB.config"

# testing only
ADDITIONAL_PATH="/database/"


DB_HOST="localhost"

DB_PORT="3306"
DATABASE="wotlkmangos"
DATAREALM="woltkrealmd"
DATACHARAC="wotlkcharacters"
USERNAME="root"
PASSWORD=mangos
MYSQL="mysql"
CORE_PATH="/database/"
DEV_UPDATES="NO"
FORCE_WAIT="NO"

export MYSQL_PWD="$PASSWORD"
MYSQL_COMMAND="mysql -uroot -p --database=$DATABASE"
MYSQL_COMMAND2="mysql  -uroot -p --database=$DATAREALM"
MYSQL_COMMAND3="mysql  -uroot -p --database=$DATACHARAC"

## Print header
echo
echo "Welcome to the WoTLK-DB helper $SCRIPT_FILE"
echo

if [ "$FORCE_WAIT" != "NO" ]
then
  echo "ATTENTION: Your database $DATABASE will be reset to WoTLK-DB!"
  echo "Please bring your repositories up-to-date!"
  echo "Press CTRL+C to exit"
  # show a mini progress bar
  for i in {1..10}
  do
   echo -ne .
   sleep 1
  done
  echo .
fi

## Create empty databases
echo "> Create empty databases..."
mysql -uroot -p < "${ADDITIONAL_PATH}create/db_create_mysql.sql"
if [[ $? != 0 ]]
then
  echo "ERROR: cannot apply ${ADDITIONAL_PATH}create/db_create_mysql.sql"
  exit 1
fi
echo "  Empty databases created!"
echo
echo

## Initialize Mangos database
echo ""
$MYSQL_COMMAND < "${ADDITIONAL_PATH}base/mangos.sql"
if [[ $? != 0 ]]
then
  echo "ERROR: cannot apply ${ADDITIONAL_PATH}base/mangos.sql"
  exit 1
fi
echo "  Mangos database initialized!"
echo
echo

## Initialize DBC data
echo "Initialize DBC original_data..."
for sql_file in $(ls ${ADDITIONAL_PATH}base/dbc/original_data/*.sql); do
$MYSQL_COMMAND < $sql_file ; done
echo "Initialize DBC cmangos_fixes..."
for sql_file in $(ls ${ADDITIONAL_PATH}base/dbc/cmangos_fixes/*.sql); do
$MYSQL_COMMAND < $sql_file ; done
echo "done..."

## Initialize characters database
echo "Initialize characters database..."
$MYSQL_COMMAND3 < "${ADDITIONAL_PATH}base/characters.sql"
if [[ $? != 0 ]]
then
  echo "ERROR: cannot apply ${ADDITIONAL_PATH}base/characters.sql"
  exit 1
fi
echo "  characters database initialized!"
echo
echo

## Initialize realmd database
echo "Initialize realmd database"
$MYSQL_COMMAND2 < "${ADDITIONAL_PATH}base/realmd.sql"
if [[ $? != 0 ]]
then
  echo "ERROR: cannot apply ${ADDITIONAL_PATH}base/realmd.sql"
  exit 1
fi
echo "  Mangos database initialized!"
echo
echo

## Full Database
echo "> Processing WoTLK database $DB_TITLE ..."
$MYSQL_COMMAND < "${ADDITIONAL_PATH}Full_DB/$FULLDB_FILE"
if [[ $? != 0 ]]
then
  echo "ERROR: cannot apply ${ADDITIONAL_PATH}Full_DB/$FULLDB_FILE"
  exit 1
fi
echo "  $DB_TITLE is applied!"
echo
echo

## Updates
echo "> Processing database updates ..."
COUNT=0
for UPDATE in "${ADDITIONAL_PATH}Updates/"[0-9]*.sql
do
  if [ -e "$UPDATE" ]
  then
    echo "    Appending $UPDATE"
    $MYSQL_COMMAND < "$UPDATE"
    if [[ $? != 0 ]]
    then
      echo "ERROR: cannot apply $UPDATE"
      exit 1
    fi
    ((COUNT++))
  fi
done
if [ "$COUNT" != 0 ]
then
  echo "  $COUNT DB updates applied successfully"
else
  echo "  Did not find any new DB update to apply"
fi
echo
echo

## Instances
echo "> Processing instance files ..."
COUNT=0
for INSTANCE in "${ADDITIONAL_PATH}Updates/Instances/"[0-9]*.sql
do
  if [ -e "$INSTANCE" ]
  then
    echo "    Appending $INSTANCE"
    $MYSQL_COMMAND < "$INSTANCE"
    if [[ $? != 0 ]]
    then
      echo "ERROR: cannot apply $INSTANCE"
      exit 1
    fi
    ((COUNT++))
  fi
done
if [ "$COUNT" != 0 ]
then
  echo "  $COUNT Instance files applied successfully"
else
  echo "  Did not find any instance file to apply"
fi
echo
echo

#
#               Core updates
#

echo "> Trying to retrieve last core update packaged in database ..."
LAST_CORE_REV=0
CORE_REVS="$(grep -r "^.*required_[0-9]*.* DEFAULT NULL" ${ADDITIONAL_PATH}Full_DB/* | sed 's/.*required_\([0-9]*\).*/\1/') "
CORE_REVS+=$(grep -ri '.*alter table.*required_' ${ADDITIONAL_PATH}Updates/* | sed 's/.*required_\([0-9]*\).*required_\([0-9]*\).*/\1 \2/')
if [ "$CORE_REVS" != "" ]
then
  for rev in $CORE_REVS
  do
    if [ "$rev" -gt "$LAST_CORE_REV" ]
    then
      LAST_CORE_REV=$rev
    fi
  done
fi

if [ "$LAST_CORE_REV" -eq "0" ]
then
  echo "ERROR: cannot get last core revision in DB"
  exit 1
else
  echo "  Found last core revision in DB is $LAST_CORE_REV"
fi
echo
echo

# process future release folders
if [ "$CORE_PATH" != "" ]
then
  if [ ! -e $CORE_PATH ]
  then
    echo "Path to core provided, but directory not found! $CORE_PATH"
    exit 1
  fi
  UPD_PROCESSED=0
  UPD_FOUND=0

  for NEXT_MILESTONE in ${NEXT_MILESTONES};
  do
    # A new milestone was released, apply additional updates
    if [ -e ${CORE_PATH}/sql/updates/${NEXT_MILESTONE}/ ]
    then
      echo "> Trying to apply core updates from milestone $NEXT_MILESTONE ..."
      for f in "${CORE_PATH}/sql/archives/${NEXT_MILESTONE}/"*_mangos_*.sql
      do
        CUR_REV=$(basename "$f" | sed 's/^\([0-9]*\).*/\1/')
        if [ "$CUR_REV" -gt "$LAST_CORE_REV" ]
        then
          # found a newer core update file
          echo "    Appending core update `basename $f` to database $DATABASE"
          $MYSQL_COMMAND < $f
          if [[ $? != 0 ]]
          then
            echo "ERROR: cannot apply $f"
            exit 1
          fi
          ((UPD_PROCESSED++))
        else
          ((UPD_FOUND++))
        fi
      done
    fi
  done

  # Apply remaining files from main folder
  echo "> Trying to apply additional core updates from path $CORE_PATH ..."
  for f in "$CORE_PATH/sql/updates/mangos/"*_mangos_*.sql
  do
    CUR_REV=$(basename "$f" | sed 's/^\([0-9]*\).*/\1/')
    if [ "$CUR_REV" -gt "$LAST_CORE_REV" ]
    then
      # found a newer core update file
      echo "    Appending core update `basename $f` to database $DATABASE"
      $MYSQL_COMMAND < $f
      if [[ $? != 0 ]]
      then
        echo "ERROR: cannot apply $f"
        exit 1
      fi
      ((UPD_PROCESSED++))
    else
      ((UPD_FOUND++))
    fi
  done
  echo "  CORE UPDATE PROCESSED: $UPD_PROCESSED"
  echo "  CORE UPDATE FOUND BUT ALREADY IN DB: $UPD_FOUND"
  echo
  echo
  
  # Apply dbc folder
  echo "> Trying to apply $CORE_PATH/sql/base/dbc/original_data ..."
  for f in "$CORE_PATH/sql/base/dbc/original_data/"*.sql
  do
    echo "    Appending DBC file update `basename $f` to database $DATABASE"
    $MYSQL_COMMAND < $f
    if [[ $? != 0 ]]
    then
      echo "ERROR: cannot apply $f"
      exit 1
    fi
  done
  echo "  DBC datas successfully applied"
  echo
  echo
  # Apply dbc changes (specific fixes to known wrong/missing data)
  echo "> Trying to apply $CORE_PATH/sql/base/dbc/cmangos_fixes ..."
  for f in "$CORE_PATH/sql/base/dbc/cmangos_fixes/"*.sql
  do
    echo "    Appending CMaNGOS DBC file fixes `basename $f` to database $DATABASE"
    $MYSQL_COMMAND < $f
    if [[ $? != 0 ]]
    then
      echo "ERROR: cannot apply $f"
      exit 1
    fi
  done
  echo "  DBC changes successfully applied"
  echo
  echo

  # Apply scriptdev2.sql
  echo "> Trying to apply $CORE_PATH/sql/scriptdev2/scriptdev2.sql ..."
  $MYSQL_COMMAND < $CORE_PATH/sql/scriptdev2/scriptdev2.sql
  if [[ $? != 0 ]]
  then
    echo "ERROR: cannot apply $CORE_PATH/sql/scriptdev2/scriptdev2.sql"
    exit 1
  fi
  echo "  ScriptDev2 successfully applied"
  echo
  echo
fi

#
#               ACID Full file
#
# Apply acid_wotlk.sql
echo "> Trying to apply ${ADDITIONAL_PATH}ACID/acid_wotlk.sql ..."
$MYSQL_COMMAND < ${ADDITIONAL_PATH}ACID/acid_wotlk.sql
if [[ $? != 0 ]]
then
  echo "ERROR: cannot apply ${ADDITIONAL_PATH}ACID/acid_wotlk.sql"
  exit 1
fi
echo "  ACID successfully applied"
echo
echo

#
#    DEVELOPERS UPDATES
#
if [ "$DEV_UPDATES" == "YES" ]
then
  echo "> Trying to apply development updates ..."
  for UPDATEFILE in ${ADDITIONAL_PATH}dev/*.sql
  do
    if [ -e "$UPDATEFILE" ]
    then
        for UPDATE in ${ADDITIONAL_PATH}dev/*.sql
        do
            echo "    process update $UPDATE"
            $MYSQL_COMMAND < $UPDATE
            [[ $? != 0 ]] && exit 1
        done
        echo "  Development updates applied"
    else
        echo "  No development update to process"
    fi
    break
  done
  for UPDATEFILE in ${ADDITIONAL_PATH}dev/*/*.sql
  do
    if [ -e "$UPDATEFILE" ]
    then
        for UPDATE in ${ADDITIONAL_PATH}dev/*/*.sql
        do
            echo "    process update $UPDATE"
            $MYSQL_COMMAND < $UPDATE
            [[ $? != 0 ]] && exit 1
        done
        echo "  Development subupdates applied"
    else
        echo "  No development subupdate to process"
    fi
    break
  done
  echo
  echo
fi

echo "You have now a clean and recent WoTLK-DB database loaded into $DATABASE"
echo "Enjoy using WoTLK-DB"
echo

if [ "${DUMP}" = "YES" ]; then
	printf "Dumping database information...\n"
	echo "${DB_HOST};${DB_PORT};${USERNAME};${PASSWORD};${wotlkrealmd}" > ~/db.conf
	echo "${DB_HOST};${DB_PORT};${USERNAME};${PASSWORD};${wotlkmangos}" >> ~/db.conf
	echo "${DB_HOST};${DB_PORT};${USERNAME};${PASSWORD};${wotlkcharacters}" >> ~/db.conf
fi


printf "Database creation and load complete :-)\n"
printf "\n"
printf "Updating Docker Host IP and/or WAN IP into realm database\n"
printf "\n"
echo mysql -u root -pmangos -e \'update wotlkrealmd.realmlist SET localAddress='"'$DOCKER_HOST_IP'" 'WHERE id='1'';'\' > /install/updateip.sh
echo mysql -u root -pmangos -e \'update wotlkrealmd.realmlist SET address='"'$WAN_IP_ADDRESS'" 'WHERE id='1'';'\' >> /install/updateip.sh
chmod +x /install/updateip.sh
/install/updateip.sh
printf "Updated Docker Host IP into realm database\n"
printf "\n"
