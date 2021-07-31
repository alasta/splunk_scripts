# Readme

## splunk_showme.sh
### Description :
Script to get local informations with CLI commands or API.  

It based on :
- https://docs.splunk.com/Documentation/Splunk/latest/RESTREF/RESTintrospect (info, show and display without arguments)
- https://docs.splunk.com/Documentation/Splunk/latest/Admin/CLIadmincommands
  
Tested on Splunk 8.0.6.
Script version 0.1.  
  
### Usage :
#### Help :
```bash
$ ./splunk_showme.sh -h

Usage : splunk_showme.sh [-e] [-i] [-h] [-D] [-v] [-o <output file>]

   -e : Execute script
   -i : Display commands informations
   -h : Help
   -D : Debug script
   -o : Write output in a file
   -v : Display version

Note :
Splunk URL based on : https://docs.splunk.com/Documentation/Splunk/latest/RESTREF/RESTintrospect
Splunk CLI based on : https://docs.splunk.com/Documentation/Splunk/latest/Admin/CLIadmincommands (list, show and display without arg)
```
  
#### Information :
Enumerate all available commands
```bash
$ ./splunk_showme.sh -i
0 - Display Splunk Version - SPLUNKCLI - splunk version
1 - Display Splunk monitor - SPLUNKCLI - splunk list monitor
2 - Display Splunk GUID - CLI - /bin/cat /opt/splunk/etc/instance.cfg
3 - Display Splunk servername - SPLUNKCLI - splunk show servername
4 - Display Splunk default-hostname - SPLUNKCLI - splunk show default-hostname
5 - Display Splunk minfreemb (Free space in Mb to SPLUNKHOME) - SPLUNKCLI - splunk show minfreemb
6 - Display Splunk boot-start - SPLUNKCLI - splunk display boot-start
7 - Display Splunkd port - SPLUNKCLI - splunk show splunkd-port
8 - Display Splunk web port - SPLUNKCLI - splunk show web-port
9 - Display Splunk kvstore port - SPLUNKCLI - splunk show kvstore-port
10 - Display Splunk cluster-bundle-status - SPLUNKCLI - splunk show cluster-bundle-status
11 - Display Splunk datastore-dir - SPLUNKCLI - splunk show datastore-dir
......
90 - Display kernel informations - CLI - /bin/uname -a
91 - Display short disk information - CLI - /bin/df -Th
92 - EXECUTE ALL COMMANDS - ALL - 
93 - EXIT SCRIPT - QUIT -
```


#### Execute :
```bash
$ ./splunk_showme.sh -e
0 - Display Splunk Version
1 - Display Splunk monitor
2 - Display Splunk GUID
3 - Display Splunk servername
....
91 - Display short disk information
92 - EXECUTE ALL COMMANDS
93 - EXIT SCRIPT



Command number to execute ? 17
Splunk user : admin
Splunk password : 


Command choice : Display Splunkd status
  Command execution : splunk status splunkd
  Output :

splunkd is running (PID: 1332).
splunk helpers are running (PIDs: 1336 1350 1506 1562).
```

Note : in this version **92** execute all commands.  
You can add **-o outputfile.log** to save in a file all output (without keyboard inputs).  


### Add command :

#### There are 3 commands types :
- SPLUNKCLI : Splunk command : $SPLUNK_HOME/bin/splunk ...
- SPLUNKURL : Splunk local API : https://127.0.0.1:8089/...
- CLI : System/OS command

#### Array syntax :
Array declaration :  
- indice 0 : Short desc of command
- indice 1 : Command or URL
- indice 2 : Type of command : CLI/SPLUNKCLI/SPLUNKURL, ALL and QUIT are reserved
- indice 3 : Ask authentication : 0=No 1=Yes

#### SPLUNKCLI :
Add array entry/block :
```bash
arr[0,"${index}"]="Display Splunk ......."
arr[1,"${index}"]="splunk ....."
arr[2,"${index}"]="SPLUNKCLI"
arr[3,"${index}"]="1"
let "index++"
```
To indice 1, the default path is **$SPLUNK_HOME/bin/**.  
Note : command without argument.  

#### SPLUNKURL :
Add array entry/block :
```bash
arr[0,"${index}"]="Get desc......"
arr[1,"${index}"]="/URI/PATH"
arr[2,"${index}"]="SPLUNKURL"
arr[3,"${index}"]="1"
let "index++"
```
To indice 1, add URI (after **https://127.0.0.1:8089/**).  

#### CLI :
Add array entry/block :
```bash
arr[0,"${index}"]="Command informations"
arr[1,"${index}"]="BINARY_PATH with option"
arr[2,"${index}"]="CLI"
arr[3,"${index}"]="0"
let "index++"
```
Note : command without authentication.  
