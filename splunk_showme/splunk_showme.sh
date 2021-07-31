#!/bin/bash
  
######################################################
#
#  Create by : Alasta
#  Date : 20210727
#
#  Desc : Get informations from Splunk commands
#
#  Usage : ./splunk_showme.sh -e
#
######################################################







##### VAR BEGIN

BIN_CAT="/bin/cat"
BIN_CURL="/bin/curl"
BIN_DF="/bin/df"
BIN_ECHO="/bin/echo"
BIN_HOSTNAME="/usr/bin/hostname"
BIN_HOSTNAMECTL="/bin/hostnamectl"
BIN_UNAME="/bin/uname"

C_VERSION="0.1"
C_SPLUNK_PORT_MGMT="8089"
C_SPLUNK_HOST="127.0.0.1"

C_EXECUTE="0"
C_INFO="0"
C_FILE_LOG=""


# Help function
function  f_help {
        echo ""
        echo "Usage : $(basename $0) [-e] [-i] [-h] [-D] [-v] [-o <output file>]"
        echo ""
        echo "   -e : Execute script"
        echo "   -i : Display commands informations"
        echo "   -h : Help"
        echo "   -D : Debug script"
        echo "   -o : Write output in a file"
        echo "   -v : Display version"
        echo ""
        echo "Note :"
        echo "Splunk URL based on : https://docs.splunk.com/Documentation/Splunk/latest/RESTREF/RESTintrospect"
				echo "Splunk CLI based on : https://docs.splunk.com/Documentation/Splunk/latest/Admin/CLIadmincommands (list, show and display without arg)"
        echo ""
}


#check if args are set
if [ "$#" -eq 0 ]
then
  f_help
  exit 1
fi



function f_outputfile () {
  exec > >(tee "${C_FILE_LOG}") 2>&1
}


#setup $SPLUNK_HOME
#https://docs.splunk.com/Documentation/CoE/ssf/Handbook/UnixProfile
for SPLUNK_HOME in "/Applications/Splunk" "/Applications/SplunkForwarder" "/opt/splunk" "/opt/splunkforwarder" "/Applications/SplunkBeta" "/Applications/SplunkForwarderBeta" "${HOME}/splunkforwarder";
do
        if [ -d "${SPLUNK_HOME}" ]; then
                break
        fi
done

if [ "${SPLUNK_HOME}" == "" ];then
        echo "WARNING: SPLUNK_HOME env variable undefined"
fi
export SPLUNK_HOME

#definition du PATH pour le bin splunk
export PATH=$PATH:"${SPLUNK_HOME}"/bin/


function f_splunklogout () {
  ##Splunk logout to prevent admin privilege
  splunk logout	2>&1 > /dev/null
}

function f_cleanup() {
	trap - SIGINT SIGTERM ERR EXIT
	# script cleanup here
	f_splunklogout	
}

#track sig to cleanup
trap f_cleanup SIGINT SIGTERM ERR EXIT

#Array declaration :
# indice 0 : Short desc of command
# indice 1 : Command or URL
# indice 2 : Type of command : CLI/SPLUNKCLI/SPLUNKURL, ALL and QUIT are reserved
# indice 3 : Ask auth : 0=No 1=Yes


#init index
index=0

declare -A arr
arr[0,"${index}"]="Display Splunk Version"
arr[1,"${index}"]="splunk version"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk monitor"
arr[1,"${index}"]="splunk list monitor"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk GUID"
arr[1,"${index}"]="${BIN_CAT} ${SPLUNK_HOME}/etc/instance.cfg"
arr[2,"${index}"]="CLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk servername"
arr[1,"${index}"]="splunk show servername"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk default-hostname"
arr[1,"${index}"]="splunk show default-hostname"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk minfreemb (Free space in Mb to SPLUNKHOME)"
arr[1,"${index}"]="splunk show minfreemb"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk boot-start"
arr[1,"${index}"]="splunk display boot-start"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="0"
let "index++"

arr[0,"${index}"]="Display Splunkd port"
arr[1,"${index}"]="splunk show splunkd-port"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk web port"
arr[1,"${index}"]="splunk show web-port"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk kvstore port"
arr[1,"${index}"]="splunk show kvstore-port"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk cluster-bundle-status"
arr[1,"${index}"]="splunk show cluster-bundle-status"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk datastore-dir"
arr[1,"${index}"]="splunk show datastore-dir"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk shcluster-kvmigration-status"
arr[1,"${index}"]="splunk show shcluster-kvmigration-status"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk Apps"
arr[1,"${index}"]="splunk display app"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk default index"
arr[1,"${index}"]="splunk show default-index"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk list index"
arr[1,"${index}"]="splunk list index"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk kvstore status"
arr[1,"${index}"]="splunk show kvstore-status"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunkd status"
arr[1,"${index}"]="splunk status splunkd"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"
 
arr[0,"${index}"]="Display Splunk Webstatus"
arr[1,"${index}"]="splunk status splunkweb"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk forward server"
arr[1,"${index}"]="splunk list forward-server"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk DS"
arr[1,"${index}"]="splunk show deploy-poll"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk collect state"
arr[1,"${index}"]="splunk list inputstatus"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk users"
arr[1,"${index}"]="splunk list user"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk peer-buckets"
arr[1,"${index}"]="splunk list peer-buckets"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk peer-info"
arr[1,"${index}"]="splunk list peer-info"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk licenser-pools"
arr[1,"${index}"]="splunk list licenser-pools"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk dist-search"
arr[1,"${index}"]="splunk display dist-search"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk local-index"
arr[1,"${index}"]="splunk display local-index"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk listen"
arr[1,"${index}"]="splunk display listen"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk cluster-buckets"
arr[1,"${index}"]="splunk list cluster-buckets"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk cluster-config"
arr[1,"${index}"]="splunk list cluster-config"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk cluster-generation"
arr[1,"${index}"]="splunk list cluster-generation"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk cluster-peers"
arr[1,"${index}"]="splunk list cluster-peers"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk deploy-clients"
arr[1,"${index}"]="splunk list deploy-clients"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk deploy-client"
arr[1,"${index}"]="splunk display deploy-client"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk deploy-server"
arr[1,"${index}"]="splunk display deploy-server"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk excess-buckets"
arr[1,"${index}"]="splunk list excess-buckets"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk exec"
arr[1,"${index}"]="splunk list exec"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk licenser-groups"
arr[1,"${index}"]="splunk list licenser-groups"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk licenser-localslave"
arr[1,"${index}"]="splunk list licenser-localslave"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk licenser-messages"
arr[1,"${index}"]="splunk list licenser-messages"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk licenser-slaves"
arr[1,"${index}"]="splunk list licenser-slaves"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk licenser-stacks"
arr[1,"${index}"]="splunk list licenser-stacks"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk licenses"
arr[1,"${index}"]="splunk list licenses"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk jobs"
arr[1,"${index}"]="splunk list jobs"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk master-info,"
arr[1,"${index}"]="splunk list master-info,"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk perfmon"
arr[1,"${index}"]="splunk list perfmon"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk saved-search"
arr[1,"${index}"]="splunk list saved-search"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk search-server"
arr[1,"${index}"]="splunk list search-server"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk tcp"
arr[1,"${index}"]="splunk list tcp"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk udp"
arr[1,"${index}"]="splunk list udp"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk wmi"
arr[1,"${index}"]="splunk list wmi"
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get resource utilization information"
arr[1,"${index}"]="/services/server/status/resource-usage"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get disk I/O statistics"
arr[1,"${index}"]="/services/server/status/resource-usage/iostats"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get host-level, dynamic CPU utilization and paging information"
arr[1,"${index}"]="/services/server/status/resource-usage/hostwide"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get process operating system resource utilization information"
arr[1,"${index}"]="/services/server/status/resource-usage/splunk-processes"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk partitions-space"
arr[1,"${index}"]="/services/server/status/partitions-space"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display Splunk sysinfo"
arr[1,"${index}"]="/services/server/sysinfo"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="List the Splunk deployment volumes"
arr[1,"${index}"]="/services/data/index-volumes"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="List the recognized indexes on the server"
arr[1,"${index}"]="/services/data/indexes"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="List bucket attributes for all indexes"
arr[1,"${index}"]="/services/data/indexes-extended"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Gets current summary disk usage information"
arr[1,"${index}"]="/services/data/summaries"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get the health status of a distributed deployment"
arr[1,"${index}"]="/services/server/health/deployment"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get health status of distributed deployment features"
arr[1,"${index}"]="/services/server/health/deployment/details"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get the health status of splunkd"
arr[1,"${index}"]="/services/server/health/splunkd"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get health status of splunkd features"
arr[1,"${index}"]="/services/server/health/splunkd/details"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="List configuration information for the splunkd health report"
arr[1,"${index}"]="/services/server/health-config"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get Splunk instance information"
arr[1,"${index}"]="/services/server/info"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="List introspection resources"
arr[1,"${index}"]="/services/server/introspection"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get indexer status information"
arr[1,"${index}"]="/services/server/introspection/indexer"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="List app KV store resources"
arr[1,"${index}"]="/services/server/introspection/kvstore"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get collection storage statistics"
arr[1,"${index}"]="/services/server/introspection/kvstore/collectionstats"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get the status of the replica set from the point of view of the current server"
arr[1,"${index}"]="/services/server/introspection/kvstore/replicasetstats"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get an overview of the database process state"
arr[1,"${index}"]="/services/server/introspection/kvstore/serverstatus"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Enumerate scheduled search details"
arr[1,"${index}"]="/services/server/introspection/search/dispatch"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Enumerate routine distributed search method execution times for each peer"
arr[1,"${index}"]="/services/server/introspection/search/dispatch/Bundle_Directory_Reaper"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Enumerate average and maximum time for user search quota computation"
arr[1,"${index}"]="/services/server/introspection/search/dispatch/Compute_User_Search_Quota"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Show dispatch directory reaper times for reaping stale artifacts"
arr[1,"${index}"]="/services/server/introspection/search/dispatch/Dispatch_Directory_Reaper"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Enumerate average and maximum time for search preprocessing before startup"
arr[1,"${index}"]="/services/server/introspection/search/dispatch/Search_StartUp_Time"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Enumerate routine distributed search method execution times for each peer"
arr[1,"${index}"]="/services/server/introspection/search/distributed"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Enumerate scheduled search details"
arr[1,"${index}"]="/services/server/introspection/search/saved"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Enumerate server/status endpoints"
arr[1,"${index}"]="/services/server/status"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get information about dispatched search jobs"
arr[1,"${index}"]="/services/server/status/dispatch-artifacts"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Access private BTree database information"
arr[1,"${index}"]="/services/server/status/fishbucket"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Check file integrity status"
arr[1,"${index}"]="/services/server/status/installed-file-integrity"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Get search concurrency limits for a standalone Splunk Enterprise instance"
arr[1,"${index}"]="/services/server/status/limits/search-concurrency"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="List deployment bookmarks"
arr[1,"${index}"]="/services/services/saved/bookmarks/monitoring_console"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"

arr[0,"${index}"]="Display system hostname"
arr[1,"${index}"]="${BIN_HOSTNAME} -A"
arr[2,"${index}"]="CLI"
arr[3,"${index}"]="0"
let "index++"

arr[0,"${index}"]="Display system informations"
arr[1,"${index}"]="${BIN_CAT} /etc/os-release"
arr[2,"${index}"]="CLI"
arr[3,"${index}"]="0"
let "index++"

arr[0,"${index}"]="Display system informations 2"
arr[1,"${index}"]="${BIN_HOSTNAMECTL}"
arr[2,"${index}"]="CLI"
arr[3,"${index}"]="0"
let "index++"

arr[0,"${index}"]="Display kernel informations"
arr[1,"${index}"]="${BIN_UNAME} -a"
arr[2,"${index}"]="CLI"
arr[3,"${index}"]="0"
let "index++"

arr[0,"${index}"]="Display short disk information"
arr[1,"${index}"]="${BIN_DF} -Th"
arr[2,"${index}"]="CLI"
arr[3,"${index}"]="0"
let "index++"

arr[0,"${index}"]="EXECUTE ALL COMMANDS"
arr[1,"${index}"]=""
arr[2,"${index}"]="ALL"
arr[3,"${index}"]="0"
let "index++"

arr[0,"${index}"]="EXIT SCRIPT"
arr[1,"${index}"]=""
arr[2,"${index}"]="QUIT"
arr[3,"${index}"]="0"
let "index++"



function f_splunkcli () {
  echo "Command choice : ${arr[0,${nbcmd}]}"
  echo "  Command execution : ${arr[1,${nbcmd}]}"
  echo -e "  Output :\n"
  if [ "${arr[3,${nbcmd}]}" -eq "1" ]
  then 
    ${arr[1,${nbcmd}]} -auth ${user}:${mdp}
  else
    ${arr[1,${nbcmd}]}
  fi

  echo -e "\n\n"
}

function f_cli () {
  echo "Command choice : ${arr[0,${nbcmd}]}"
  echo "  Command execution : ${arr[1,${nbcmd}]}"
  echo -e "  Output :\n"
	${arr[1,${nbcmd}]}
  echo -e "\n\n"
}

function f_splunkurl () {
  echo "Command choice : ${arr[0,$nbcmd]}"
  echo "  Target URL : https://${C_SPLUNK_HOST}:${C_SPLUNK_PORT_MGMT}${arr[1,$nbcmd]}"
  echo -e "  Output :\n"
	"${BIN_CURL}" -s -X GET -u  ${user}:${mdp} -k "https://${C_SPLUNK_HOST}:${C_SPLUNK_PORT_MGMT}${arr[1,${nbcmd}]}"
  echo -e "\n\n"
}





function f_asksplunkaccount () {
  if [ "${1}" -eq 1 ]
  then
    # Ask splunk account
    echo -n "Splunk user : "
    read -r user
    echo -n "Splunk password : "
    trap "stty echo" EXIT HUP INT QUIT
    stty -echo
    read -r mdp
    stty echo
    trap - EXIT HUP INT QUIT
    echo -e "\n\n"
  fi
}

function f_listcommand () {
  #Number of choice (array size/number of column)
  nbcolumn=(${#arr[@]}/4)

  for (( i=0; i<${nbcolumn}; i++ ))
    do
    if [ "${C_INFO}" -eq "1" ]
    then
      echo "$i - ${arr[0,${i}]} - ${arr[2,${i}]} - ${arr[1,${i}]}"
    else
     echo "$i - ${arr[0,${i}]}" 
    fi
  done
}

function f_executeallcommand () {
  #Force ask splunk account 
  f_asksplunkaccount 1
  #the -2 is to exclude reserved command (ALL and QUIT)`
  for (( nbcmd=0; nbcmd<("${nbcolumn}"-2); nbcmd++ ))
  do
  case "${arr[2,${nbcmd}]}" in
    SPLUNKCLI)
      f_splunkcli "${nbcmd}"
      ;;
    CLI)
      f_cli "${nbcmd}"
      ;;
    SPLUNKURL)
      f_splunkurl "${nbcmd}"
      ;;
    *)
      echo "Unknown command"
      ;;
  esac
    
  done
}

function f_askcommandtoexecute () {
  echo -e "\n\n"
  echo -n "Command number to execute ? "
  read -r nbcmd

  case "${arr[2,${nbcmd}]}" in
    SPLUNKCLI)
      f_asksplunkaccount "${arr[3,${nbcmd}]}"
      f_splunkcli "${nbcmd}"
      ;;
    CLI)
      f_asksplunkaccount "${arr[3,${nbcmd}]}"
      f_cli "${nbcmd}"
      ;;
    SPLUNKURL)
      f_asksplunkaccount "${arr[3,${nbcmd}]}"
      f_splunkurl "${nbcmd}"
      ;;
    ALL)
      f_executeallcommand
      ;;
    QUIT) 
      ##Logout Splunk
      f_splunklogout
      exit 0
      ;;
    *)
      echo "Unknown command"
      ;;
  esac
}


#Manage options
while getopts "eihDvo:" option
do
  case "${option}" in
  e) C_EXECUTE="1"
     ;;
  i) C_INFO="1"
     f_listcommand
     exit 3
     ;;
  D) set -x; shift 
     ;;
  h) f_help
     exit 1
     ;;
  o) C_FILE_LOG="${OPTARG}"; shift 2
     f_outputfile
     ;;
  v) echo "Splunk Show Me version : ${C_VERSION}"
     exit 0
     ;;
  \?)echo "*** Error ***"
     exit 2
     ;;
  :) echo "*** Option \"${OPTARG}\" not set ***"
     exit 4
     ;;
  *) echo "*** Option \"${OPTARG}\" unknown ***"
     exit 5
     ;;
  esac
done


f_listcommand
f_askcommandtoexecute


##Logout Splunk
f_splunklogout


