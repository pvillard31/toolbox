#!/bin/sh

use() {
  echo "#######################################################################"
  echo "### $0 <ambari host> <ambari login> <ambari password> <cluster name> <target host>"
  echo "#######################################################################"
  echo "#"
  echo "# This script can be used to restart all the components installed on a"
  echo "# given node using the Ambari REST API. First, it makes a call to get the"
  echo "# list of the compenents and then ask to restart all the components."
  echo "#"
  echo "#######################################################################"
  exit 1
}

AMBARI=$1
LOGIN=$2
PASSWORD=$3
CLUSTER=$4
HOST=$5

if [ $# -ne 5 ]; then
  use
fi

JSON=`curl -k -s -u ${LOGIN}:${PASSWORD} -X GET http://"${AMBARI}":8080/api/v1/clusters/"${CLUSTER}"/hosts/"${HOST}"/host_components?fields=HostRoles/service_name | grep -E "component_name|service_name" | sed -e '1d' -e 'N;s/\n/ /' -e 's/ //g' -e 's/\(.*\)/{\1,"hosts":"'${HOST}'"},/g' -e '$ s/.$//'`

FULLJSON='{"RequestInfo":{"command":"RESTART","context":"Restart all components on '${HOST}'"},"Requests/resource_filters":['${JSON}']}'

curl -k -s -u ${LOGIN}:${PASSWORD} -H "X-Requested-By: ambari" -X POST --data "${FULLJSON}" http://"${AMBARI}":8080/api/v1/clusters/"${CLUSTER}"/requests

exit $?
