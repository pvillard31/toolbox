#! /usr/bin/python
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

import subprocess
import json
import datetime

_ambari_api_url = "http://127.0.0.1:8080/api/v1/clusters"
_ambari_user = "admin"
_ambari_pwd = "admin"
_cluster_name = "mycluster"

_stack_version_endpoint = _ambari_api_url + "/" + _cluster_name + "/stack_versions"
_services_endpoint = _ambari_api_url + "/" + _cluster_name + "/services"
_hosts_endpoint = _ambari_api_url + "/" + _cluster_name + "/hosts"
_blueprint_endpoint = _ambari_api_url + "/" + _cluster_name + "?format=blueprint"

def execute( url ):
	p = subprocess.Popen("curl -u " + _ambari_user + ":" + _ambari_pwd + " " + url, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	out, err = p.communicate()
	if p.returncode == 0:
		return out
	else:
		print "Failed to get token"
		print err
		print out
		return None


def printStackVersions():
    stacks = json.loads(execute(_stack_version_endpoint))

    for stack in stacks['items']:
        jDataStack = json.loads(execute(stack['href']))

        for repo in jDataStack['repository_versions']:
            jRepo = json.loads(execute(repo['href']))
            print (
                jDataStack['ClusterStackVersions']['stack'] + " - " +
                jDataStack['ClusterStackVersions']['version'] + " - " +
                jDataStack['ClusterStackVersions']['state'] + " - " +
                jRepo['RepositoryVersions']['repository_version']
                )

def printServices():
    services = execute(_services_endpoint)
    jServices = json.loads(services)
    for service in jServices['items']:
        components = json.loads(execute(service['href']))['components']
        print service['ServiceInfo']['service_name']
        for component in components:
            print "\t" + component['ServiceComponentInfo']['component_name'] + " - installed on " + str(len(json.loads(execute(component['href']))['host_components'])) + " nodes"

def printHosts():
    hosts = execute(_hosts_endpoint)
    jHosts = json.loads(hosts)
    print "Number of nodes: " + str(len(jHosts['items']))
    print ""

    for item in jHosts['items']:
        host = execute(item['href'])
        jHost = json.loads(host)
        print (
            item['Hosts']['host_name'] + " - " +
            jHost['Hosts']['ip'] + " - " +
            jHost['Hosts']['os_type']
            )

def printHostsList(list):
    mylist = []
    for item in list:
        mylist.append(item['HostRoles']['host_name'])
    if len(mylist) > 0:
        return '[%s]' % ', '.join(map(str, mylist))
    else:
        return ""

def printHostsPerComponent():
    services = execute(_services_endpoint)
    jServices = json.loads(services)
    for service in jServices['items']:
        components = json.loads(execute(service['href']))['components']
        print service['ServiceInfo']['service_name']
        for component in components:
            print "\t" + component['ServiceComponentInfo']['component_name'] + " - " + printHostsList(json.loads(execute(component['href']))['host_components'])

def printComponentsList(list):
    mylist = []
    for item in list:
        mylist.append(item['HostRoles']['component_name'])
    if len(mylist) > 0:
        return '[%s]' % ', '.join(map(str, mylist))
    else:
        return ""

def printComponentsPerHost():
    hosts = execute(_hosts_endpoint)
    jHosts = json.loads(hosts)
    print "Number of nodes: " + str(len(jHosts['items']))
    print ""

    for item in jHosts['items']:
        host = execute(item['href'])
        jHost = json.loads(host)
        print item['Hosts']['host_name'] + " - " + printComponentsList(jHost['host_components'])

def printBackendDatabase():
    blueprint = execute(_blueprint_endpoint)
    jBlueprint = json.loads(blueprint)
    for configuration in jBlueprint['configurations']:
        if "hive-env" in configuration:
            print "Hive database = " + configuration['hive-env']['properties']['hive_database']
        if "oozie-env" in configuration:
            print "Oozie database = " + configuration['oozie-env']['properties']['oozie_database']
        if "admin-properties" in configuration:
            print "Ranger database = " + configuration['admin-properties']['properties']['DB_FLAVOR']


now = datetime.datetime.now()
print "======================================="
print "Report generated on " + now.strftime("%Y-%m-%d %H:%M")
print "======================================="
print ""

print "--- Stacks ---"
printStackVersions()
print ""

print "--- Installed Services / Components ---"
printServices()
print ""

print "--- Hosts ---"
printHosts()
print ""

print "--- Hosts list per component ---"
printHostsPerComponent()
print ""

print "--- Components list per host ---"
printComponentsPerHost()
print ""

print "--- Backend Databases ---"
printBackendDatabase()
print ""
