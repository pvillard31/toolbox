#!/bin/sh

AMBARI=$1
LOGIN=$2
PASSWORD=$3
CLUSTER=$4
HOST=$5

JSON=`curl -k -s -u ${LOGIN}:${PASSWORD} -X GET http://"${AMBARI}":8080/api/v1/clusters/"${CLUSTER}"/hosts/"${HOST}"/host_components?fields=HostRoles/service_name | grep -E "component_name|service_name" | sed -e '1d' -e 'N;s/\n/ /' -e 's/ //g' -e 's/\(.*\)/{\1,"hosts":"'${HOST}'"},/g' -e '$ s/.$//'`

FULLJSON='{"RequestInfo":{"command":"RESTART","context":"Restart all components on '${HOST}'"},"Requests/resource_filters":['${JSON}']}'

curl -k -s -u ${LOGIN}:${PASSWORD} -H "X-Requested-By: ambari" -X POST --data "${FULLJSON}" http://"${AMBARI}":8080/api/v1/clusters/"${CLUSTER}"/requests

