#!/bin/sh

GITCHECKOUT="/Users/pierre/dev/github/nifi/"
FLOWBACKUP="/Users/pierre/dev/backup"
SENSITIVE_PROPS_KEY=`cat /Users/pierre/.nifi_sensitive_props_key`

USERNAME=pvillard
PASSWORD=mybadpassword

VERSION=`grep version $GITCHECKOUT/pom.xml | grep SNAPSHOT | head -1 | sed -e 's/.*>\(.*\)<.*/\1/g'`
NIFIHOME="$GITCHECKOUT/nifi-assembly/target/nifi-$VERSION-bin/nifi-$VERSION/"

backup_flow() {
  mv $FLOWBACKUP/flow.json.gz $FLOWBACKUP/flow.json.gz.$(date +%F_%R)
  cp $NIFIHOME/conf/flow.json.gz $FLOWBACKUP/flow.json.gz
  rm `ls -t $FLOWBACKUP | awk 'NR>30'`
}

restore_flow() {
  cp $FLOWBACKUP/flow.json.gz $NIFIHOME/conf/flow.json.gz
}

setup_nifi() {
  sed -i '' 's/#\(nifi.python.command.*\)/\1/g' $NIFIHOME/conf/nifi.properties
  sed -i '' 's/nifi.sensitive.props.key=.*/nifi.sensitive.props.key='$SENSITIVE_PROPS_KEY'/g' $NIFIHOME/conf/nifi.properties
  $NIFIHOME/bin/nifi.sh set-single-user-credentials $USERNAME $PASSWORD
}

while [[ $# -gt 0 ]]; do
  case $1 in

    --version)
      echo $VERSION
      ;;

    --stop|--start|--restart)
      $NIFIHOME/bin/nifi.sh $1
      ;;

    --home)
      echo $NIFIHOME
      ;;

    --dev)
      echo $GITCHECKOUT
      ;;

    --build)
      $NIFIHOME/bin/nifi.sh stop
      backup_flow
      cd $GITCHECKOUT
      mvn clean install -DskipTests -T4 -DallProfiles
      cd -
      restore_flow
      setup_nifi
      $NIFIHOME/bin/nifi.sh start
      ;;

    --tail)
      tail -n100 -F $NIFIHOME/logs/nifi-app.log
      ;;

    -h|--help)
      echo "nifi.sh --version | --stop | --start | --restart | --home | --dev | --build | --tail | -h,--help"
      ;;

    *)
      echo $( realpath "$0" )
      echo "Unknown arguments"
      ;;

  esac

  exit;
done

echo $( realpath "$0" )

