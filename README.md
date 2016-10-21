![librerouter - logo](https://cloud.githubusercontent.com/assets/13025157/14472862/85e49ae0-00f5-11e6-9591-163f1acd5098.png)

#Setting up a lab to start to contribute:

ESXi,VirtualBox,other vitrual lab:

Internet Router<-----eth0----Debian64----eth1---Virtual Lan vswitch<---eth---Windows10


DHCPserver--eth0---sameDebian64-----eth1--(Debian will start a dhcpserver internally)--------Win10

First of all you should install latest Debian version in a virtual machine:
- 2GB RAM, 2 procesor, 2NICs (network interfaces)


Second a non privacy friendly OS like Win 10:
- VM requirements in microsoft
- Office 2016
- All possible browsers.dropbox client, seamonkey,firefox,chrome,edge,iexplorer,opera,chromiun.

Hardware resources:

- NIC1 will be NAT/bridged to your Internet dhcp server router.
- NIC2 will be a attached  via virtual switch or vlan to the other VM Windows10. 
From debian to win 10 will be a private LAN in bridge mode. (would require promiscous because arp request from client to server)

You can use any virtualization software you prefer. Its transparent for us.

As shown in the following figure.
![deded](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/21.png)

Resume of steps:

- a) In the Debian please do a Snapshot in the Virtual machine just after being install.
- b) execute app-installation-script.

- cd /
- cd temp
- sudo wget –no-check-certificate https://raw.githubusercontent.com/Librerouter/Librekernel/gh-pages/app-installation-script.sh
- sudo chmod 777 app-installation-script.sh
- ./app-installation-script.sh

- If every finish ok then app-configuration-script.sh should be able to execute, if not please check internet conection and repeat

- c) execute app-installation-script.sh

- sudo wget –no-check-certificate https://raw.githubusercontent.com/Librerouter/Librekernel/gh-pages/app-configuration-script.sh
- sudo chmod 777 app-installation-script.sh
- ./app-installation-script.sh

Lab done!

Try to navigate normally from the windows 10
Report us problems
Investigate and play while we continue developing it.
New version of the instalaltion-configuration scripts,ISOs and OVA virtual machine export will be upcoming.

#***Networking in Librerouter:
There are two bridges with two interfaces each in PIPO in VM you dont have bridges (only 2 separated zone NICs):
	
1. External area red bridge acting as WAN (2 nics): cable or wireless interface as DHCP client of your internet router.
2. Internal area gren bridge acting as LAN (2 nics): cable or wireless interface as an AP for being DHCP server for your new secure LAN.

- Four possible PHySICAL scenarios:

 - WAN is WiFi, LAN is WiFi
 - WAN is WiFi, LAN is Cabled Ethernet
 - WAN is Cabled Ethernet, LAN is WiFi
 - WAN is Cabled Ethernet, LAN is Cabled Ethernet

**Step 2: Setup the network.**

Librerouter has two way to work: 

 - Server (no protection but services)
 - Network Router (services and network protection) (dont mix with NIC bridges that we have to separate 4 interfaces in 2 zones)
 

##Server mode

The way networking works in Librerouter will be:

![servermode](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/36.png)

 -  Fix serviceable IPs in 10.0.0.x can be wireless or Cabled Ethernet connected to the existing internet router LAN. 
 -  Server mode with both WAN and LAN interfaces in the same DMZ or VLAN or area and not threating the network traffic (not hable to defend against web browsing leaks,tracking,ads and malware)

![server](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/37.png)

![servermodeworkflow](https://cloud.githubusercontent.com/assets/13025157/14444317/f69f0ec0-0044-11e6-9c94-ad7a9c496140.png)

 
##Router bridge mode

![bridgemode](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/38.png)

Where the trafic is filtered by dns , by ip via iptables, by protocol, application layer signature and reputationally. 

![untitled](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/39.png)

![bridmodeworkflow](https://cloud.githubusercontent.com/assets/17382786/17251578/acd2871c-55a9-11e6-9e89-22252735ae39.png)


##DNS:

- Unbound-dns 
- If it is not resolved then using DNSCRYPT and using services like D.I.A.N.A (oposite of IANA) or Open NIC.
- If it can not resolved, then we need to ask through TOR.
- Further integration will include Bitname,others like DjDNS (this last need maintenance is not workinghttps://github.com/DJDNS/djdns)).

![dnsipdate](https://cloud.githubusercontent.com/assets/17382786/17974085/ec54e6b4-6ae4-11e6-9efb-bf2352520459.png)
 
  * Search engines  - will be resolved to ip address 10.0.0.251 (Yacy) by unbound.
  * Social network  - will be resolved to ip address 10.0.0.252 (friendics) by unbound.
  * Online Storage  - Will be resolved to ip address 10.0.0.253 (Owncloud) by unbound.
  * Webmails        - Will be resolved to ip address 10.0.0.254 (MailPile) by unbound.

#### Darknets Domains:
 
  * .local - will be resolved to local ip address (10.0.0.0/24 network) by unbound.
  * .i2p   - will be resolved to ip address 10.191.0.1 by unbound.
  * .onion - unbound will forward this zone to Tor DNS running on 10.0.0.1:9053
  
 -Freenet domains:> not yet implemented
- http://ftp.mirrorservice.org/sites/ftp.wiretapped.net/pub/security/cryptography/apps/freenet/fcptools/linux/gateway.html
- Bit domains> blockchain bitcoin> not yet implemented 
- https://en.wikipedia.org/wiki/Namecoin  https://bit.namecoin.info/
- Zeronet> not yet implemented
- Openbazaar> not yet implemented
![dnsipdated](https://cloud.githubusercontent.com/assets/17382786/17974408/4054bb80-6ae6-11e6-9747-a79d3d703e65.png)
 

###HSTS 
https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security

Problem: when a use uses the google/bing search by a direct query keyword in the browsers
The browser enfoces hsts then the certificate from our redirected yacy fails.
Then we cant inspect the traffic for this big list of domains:
https://cs.chromium.org/chromium/src/net/http/transport_security_state_static.json
We inspect for protecting the browser against exploitation of bugs and attacks.
Who can guaranteed this entities are not doing it?

We inspect the HSTS domains with Snort,Suricata BRO and CLamAV via ICAP CCAP and Squid bumping

The problem is that the redirection we made when the user tries gmail for instance in to local service mailpile fails with multiple browser because hsts.

Why we redirect gmail to mailpile or roundcube? obvious we offer s elfhosted solution better than corporate centralized.



#### Can the user in the future workaround it:

Yes in the future via GUI should be possible to reconfigure this cage.



#Network use cases
![network_diagram_2](https://cloud.githubusercontent.com/assets/13025157/18578293/695f395a-7bef-11e6-8d83-82d88b6b0feb.png)


 -  a) https to onion
 -  b) https to i2p
 -  c) http to onion
 -  d) http to i2p
 -  e) http with ads to internet
 -  f) https with ads to internet
 -  g) https with not allowed content porn to internet
 -  h) https to a bank
 -  i) http to a bad domain
 -  h) https to a bad domain
 -  i) https to a good domain that tries to exploit the browser via flash exploit
 -  h) https that tries to download a exe file with virus.
 -  i) http conecting to a place but this conection matches a botnet signature.
 -  j) ssh to a server between the librerouter and internet (internal lan of the user , external side of the librerouter)
 -  k) tahoe trying to use TOR or I2P addresses.
 -  l) user browser a keyword in browser formularie > browser tries to query google or duckduckgo or bing for that search.
 -  m) Attacks  to local services url from  from TOR or I2P.
 -  n) any local machine tries to go to youtube> how to macke interactive the procces where librerouter ask to the users to allow or not.
 -  o) any web tries to track via installing certificates like fb of gmail or google to spy on users.
 -  p) how the user will allow or not any IoT while is blocked in librerouter?
 -  q) what we do with udp?
 -  r) udp dns request that not goes to unbound?
 -  s) udp p2p trafic from emule?
 -  t) udp others?
 -  u) icmp ping to any IP
 -  v) non http,icmp,https,dns traffic (how layer 7 will try to identify the protocol and alert the user to allow or not)
 -  w) a request from xmmp federation from internet or from TOR or I2P
 -  x) to allow or not javascript,flash, etc on preallowed white and black list
 -  y) yacy trying to go by TOR or I2P
 -  z) prosody trying to conect via over TOR
 -  a1) webrtc protocol
 -  a2) hsts via browser direct entry for example gmaik push enter key
 -  a3) hsts via browser corrected entry form for example https://www.gmail.com enter key 

#Blocked stuff
![blocking_diagram_1](https://cloud.githubusercontent.com/assets/13025157/18578310/871cd3b2-7bef-11e6-96d2-6b45fd7662e3.png)

##Intelligence IP and Domain Providers:

- Shallalist
- mesdk12 http://squidguard.mesd.k12.or.us/blacklists.tgz
- http://urlblacklist.com/?sec=download
- https://www.iblocklist.com/lists
- http://iplists.firehol.org/
- https://github.com/rustybird/corridor
- Spamhaus
- Virustotal
- http://urlblacklist.com/

Where we use it?

##Privacy testers: We used in the browser from the simulated client with windows 10

 - https://anonymous-proxy-servers.net/en/help/security_test.html
 - www.iprivacytools.com
 - checker.samair.ru
 - https://anonymous-proxy-servers.net/en/help/security_test.html
 - https://www.onion-router.net/Tests.html
 - analyze.privacy.net
 - https://www.maxa-tools.com/cookie-privacy.php
 - https://panopticlick.eff.org/
 - https://www.perfect-privacy.com/german/webrtc-leaktest/
 - https://www.browserleaks.com/
 - browserspy.dk

##Squid tuning conf for Privacy : squid.conf 

	- via off
	- forwarded_for off
	- header_access From deny all
	- header_access Server deny all
	- header_access WWW-Authenticate deny all
	- header_access Link deny all
	- header_access Cache-Control deny all
	- header_access Proxy-Connection deny all
	- header_access X-Cache deny all
	- header_access X-Cache-Lookup deny all
	- header_access Via deny all
	- header_access Forwarded-For deny all
	- header_access X-Forwarded-For deny all
	- header_access Pragma deny all
	- header_access Keep-Alive deny all
	-   request_header_access Authorization allow all
	-   request_header_access Proxy-Authorization allow all
	-   request_header_access Cache-Control allow all
	-   request_header_access Content-Length allow all
	-   request_header_access Content-Type allow all
	-   request_header_access Date allow all
	-   request_header_access Host allow all
	-   request_header_access If-Modified-Since allow all
	-   request_header_access Pragma allow all
	-   request_header_access Accept allow all
	-   request_header_access Accept-Charset allow all
	-   request_header_access Accept-Encoding allow all
	-   request_header_access Accept-Language allow all
 	-   request_header_access Connection allow all
	-   request_header_access All deny all
	-   forwarded_for delete
	-   follow_x_forwarded_for deny all
 	-   request_header_access X-Forwarded-For deny all
	-   request_header_access From deny all
	-   request_header_access Referer deny all
	-   request_header_access User-Agent deny all

##Squid ADS :

 - https://calomel.org/squid_adservers.html
 - http://adzapper.sourceforge.net/
 - http://pgl.yoyo.org/adservers/

##Unboudndns implement list of ADs servers to be block:

 - https://github.com/jodrell/unbound-block-hosts

##Squid SSL bumping for AV SSL and IPS (intrusion prevention applied to decrypt traffic) :

 - https://hitch-tls.org/
 - https://github.com/varnish/hitch
 - https://github.com/dani87/sslbump
 - https://github.com/jpelias/squid3-ssl-bump/blob/master/Install%20Squid%203.4%20with%20ssl%20bump%20on%20Debian%208%20(Jessie)
 - https://github.com/diladele

##Squid Content filter with privacy enhacement:

 - https://github.com/andybalholm/redwood

##IDS/IPS:

 - https://github.com/aircrack-ng/OpenWIPS-n
 - https://suricata-ids.org
 - https://www.snort.org
 - https://www.bro.org
 - https://github.com/lmco/vortex-ids
 - 
##Graphical Interface for IDS/IPS:
 - https://github.com/StamusNetworks/scirius
 - https://github.com/jasonish/evebox
 - https://github.com/StamusNetworks/KTS
 - https://www.elastic.co/products/kibana
 - https://github.com/Snorby/snorby
 - https://www.prelude-siem.org/
 - https://github.com/mcholste/elsa
 - http://sguil.net
 - 
##Network forensics with netflow
 - http://www.ntop.org
 - http://www.haka-security.org/hakabana.html
 - https://sourceforge.net/p/flowviewer/wiki/Home/
 - https://github.com/aptivate/pmgraph
 - http://nfdump.sourceforge.net 



##Privoxy and Privacy options for TOR traffic:

![privoxy-rulesets-web](https://cloud.githubusercontent.com/assets/17382786/17368067/e269d884-5992-11e6-985c-618b9f5e4c8c.gif)


#NETWORK USE CASES

When user is using HTTPS connection to a darknet domain, this traffic it's considered dangerus and insecure. (the goverment try to explodes the browser for deanonymization) On darknet onion and i2p domains, squid will open the SSL tunnel and inspect for possible exploits, virus and attacks to the user.
If this connection it's to a HTTPS regular/banking domain, this SSL tunnel will be not open Bumped/inspected. Will be routed directly to the clearnet internet (ex: https://yourbank.com)

When the user is using HTTP, because is considered insecure itself this clear traffic is going to go through TOR to add anonymization but after a threatment from the local engines to add privacy on it.. The user can also decide in the future about which things he dont want to use TOr for HTTP.

- I2P domains/eepSite (ex: i2p2.i2p) will be redirected to I2P
- Hidden services (ex: asdf1234.onion) will go through TOR
- HTTP (ex: http://news.com) will go through TOR to the internet site


 
###Unbounddns server configuration.

- Is implemented by configure_unbound() function. (lines 491-726 of app-configuration-script.sh) 

###TOR configurations.
Tor dns configuration is implemented by configure_tor() function. (lines 411-474 of app-configuration-script.sh) 

###I2P configuration.

###NGINX configuration.

###Multiple Squids (darknet bumping and clearnet ssl NObump) configurations.

###Privoxy configuration.

###Iptables configuration.

####Rules Description

$INT_INTERFACE - is internal network interface

$EXT_INTERFACE - is external network interface

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.245 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.245 which is webmin ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.11 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.11 which is kibana ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.12 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.12 which is snorby ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.246 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.246 which is squidguard ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.250 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.250 which is easyrtc ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.251 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.251 which is yacy ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.252 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.252 which is friendica ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.253 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.253 which is owncloud ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.254 -j ACCEPT
 - accepts all of the tcp traffic on interface 10.0.0.254 which is mailpile ip of librerouter service

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 22 -j REDIRECT --to-ports 22
 - avoids NATing 22 port for an external ssh access

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p udp -d 10.0.0.1 --dport 53 -j REDIRECT --to-ports 53
 - avoids NATing 53 port for an external DNS access

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 80 -j REDIRECT --to-ports 80
 - avoids NATing 80 port for an external HTTP access

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 443 -j REDIRECT --to-ports 443
 - avoids NATing 443 port for an external HTTPS access

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 7000 -j REDIRECT --to-ports 7000
 - avoids NATing 7000 port for an external access

iptables -t nat -A OUTPUT     -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
 - redirects all output tcp traffic to destanation http port and destanation address 10.191.0.1 to squid-i2p service port

iptables -t nat -A PREROUTING -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
 - redirects all tcp traffic to destanation http and destanation address 10.191.0.1 to squid-i2p service port

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -m tcp --sport 80 -d 10.191.0.1 -j REDIRECT --to-ports 3128
 - redirects all tcp traffic with source http port and destanation address  10.191.0.1 to squid-i2p service port

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.0/8 -j DNAT --to 10.0.0.1:3129
 - redirects all tcp traffic from internal interface to 10.0.0.0/8 network to squid-tor service port

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --dport 80 -j DNAT --to 10.0.0.1:3130
 - redirects http traffic from internal interface to squid-http service port

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --dport 443 -j REDIRECT --to-ports 3131
 - redirects https traffic from internal interface to squid-https service port

iptables -t nat -A POSTROUTING -o $EXT_INTERFACE -j MASQUERADE 
 - rule for NATing traffic from internal to extarnal interface


###X further service configuration.

### Suricata configuration.
To provide full internet security, we want IDS/IPS to inspect all kind of communications in our network: tor, i2p and direct.
But we also want to inspect all secure connections. To do so, we use squid proxy with ssl-bump feature to perform mitm.
All decrypted traffic goes to icap server, where it's being scanned by clam antivirus.

To accomplish our goal, we are going to make Suricata listen on two interfaces:
 -  On LAN Suricata is going to detect potentially bad traffic (incoming and outgoing), block attackers/compromised hosts, tor exit nodes, etc.
Suricata will inspect packets using default sets of rules: 
  Botnet Command and Control Server Rules (BotCC),
  ciarmy.com Top Attackers List,
  Known CompromisedHost List,
  Spamhaus.org DROP List,
  Dshield Top Attackers List,
  Tor exit Nodes List,
  Protocol events List.
 -  On localhost Suricata is supposed to scan icap port for bad content: browser/activex exploits, malware, attacks, etc.
Modified emerging signatures for browsers will be implemented for this purpose.

![untitled](https://cloud.githubusercontent.com/assets/13025157/18548726/947f19fc-7b4a-11e6-8dc5-a9cd3a0f6c19.png)

**Suricata will prevent the following sets of attacks:**

a) Web Browsers
  - ActiveX Remote Code Execution
  - Microsoft IE ActiveX vulnerabilities
  - Microsoft Video ActiveX vulnerabilities
  - Snapshot Viewer for Microsoft Access ActiveX vulnerabilities
  - http backdoors (get/post)
  - DNS Poisoning
  - Suspicious/compromises hosts
  - ClickFraud URLs
  - Tor exit nodes
  - Chats vulnerabilities (Google Talk/Facebook)
  - Gaming sites vulnerabilities (Alien Arena/Battle.net/Steam)
  - Suspicious add-ins and add-ons downloading/execution
  - Javascript backdoors
  - trojans injections
  - Microsoft Internet Explorer vulnerabilities
  - Firefox vulnerabilities
  - Firefox plug-ins vulnerabilities
  - Google Chrome vulnerabilities
  - Malicious Chrome extencions
  - Android Browser vulnerabilities
  - PDF vulnerabilities
  - Stealth code execution
  - Adobe Shockwave Flash vulnerabilities
  - Adobe Flash Player vulnerabilities
  - Browser plug-in commands injections
  - Microsoft Office format vulnerabilities
  - Adobe PDF Reader vulnerabilities
  - spyware
  - adware
  - Web scans
  - SQL Injection Points
  - Suspicious self-signed sertificates
  - Dynamic DNS requests to suspicious domains
  - Metasploits
  - Suspicious Java requests
  - Suspicious python requests
  - Phishing pages
  - java.runtime execution
  - Malicious files downloading

b) Librerouter (router services)
  - mysql attacks
  - Apache/nginx Brute Force Attacks
  - GPL attack responses
  - php remote code injections
  - Apache vulnerabilities
  - Apache OGNL exploits
  - Oracle Java vulnerabilities
  - PHP exploits
  - node.js exploits
  - ssh attacks

c) User devices
  - GPL attack responses
  - Metasploit Meterpreter
  - Remote Windows command execution
  - Remote Linux command execution
  - IMAP attacks
  - pop3 attacks
  - smtp attacks
  - Messengers vulnerabilities (ICQ/MSN/Jabber/TeamSpeak)
  - Gaming software vulnerabilities (Steam/PunkBuster/Minecraft/UT/TrackMania/WoW)
  - Microsoft Windows vulnerabilities
  - OSX vulnerabilities
  - FreeBSD vulnerabilities
  - Redhat 7 vulnerabilities
  - Apple QuickTime vulnerabilities
  - RealPlayer/VLC exploits
  - Adobe Acrobat vulnerabilities
  - Worms, spambots
  - Web specific apps vulnerabilities
  - voip exploits
  - Android trojans
  - SymbOS trojans
  - Mobile Spyware
  - iOS malware
  - NetBios exploits
  - Oracle Java vulnerabilities
  - RPC vulnerabilities
  - telnet vulnerabilities
  - MS-SQL exploits
  - dll injections
  - Microsoft Office vulnerabilities
  - rsh exploits


**Loopback issue:**

Suricata >=3.1 is unable to listen on loopback in afp mode. When run with -i lo option, it dies with this messages:

\<Error\> - [ERRCODE: SC_ERR_INVALID_VALUE(130)] - Frame size bigger than block size

\<Error\> - [ERRCODE: SC_ERR_AFP_CREATE(190)] - Couldn't init AF_PACKET socket, fatal error

Same configuration works fine with Suricata v3.0.0.

**Possible solutions:**

- Use pcap mode on lo and af-packet on eth0. May not be possible, because since 3.1 Suricata use af-packet mode by default
- Reduce the MTU size



![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)





#Steps to setup on Physical/Virtual machine.

##Installation and Setup

###***Which hardware/Virtual resources you needed to run Librerouter scripts?***

Anyone able to run a Debian 8.5 ARM x86 32 or 64 bits 

- At least 2 network interfaces NICS (external and internal always no matters bridge or server mode),
- 2GB RAM
- 4 cores CPU 
- 32GB HDD but better 1TB

##Step 3. Executing scripts.

In this step you need to download and execute the following scripts on your machine with given order.


 - 0. Install a Debian 8.5 vanilla or desktop and make a Virtual Machine snapshot before anything after the installation succesfully finished. 
 - 1. driver-script-pipo.sh (bypass if your not using the PIPO hardware)
 - 2. app-installation-script.sh 
 - 3. Make (again!) a VM snapshot in the lab.
 - 3. app-configuration-script.sh
 - 4. app-post configuration encryption FDE fill disk encryption (not implemented yet)
 - 5. System GUI Wizards  (not implemented/dev yed)
 - 6. Subsystems GUIs for backends forked from IPFIRE   (not implemented/dev yed) check gui.md for further reference

###0. What the driver-script-pipo.sh  does?

Installs the drivers for Pipo X8 hardware (not necesary if you using a virtual environment):

 - WLAN 1 NON FREE
 - WLAN 1 FREE
 - TOUCH SCREEN  NON FREE
 - SOUND CARD (there is no mic in the machine)  NON FREE
 - Ethernet drivers (both usb and onboard) are free.

###1. What the app-installation-script does?

![initial-install-workflow](https://cloud.githubusercontent.com/assets/13025157/14444383/5b99d710-0045-11e6-9ae8-3efa1645f355.png)

 - Step 1. Checking user
The script should be run by user root, if it was run by another user then it will warn and exit.

 - Step 2. Checking Platform
The all software intended to run on Debian 7/8 or Ubuntu 12.04/14.04, so if script finds another platform it will output an error and exit.

 - Step 3. Checking Hardware
As software can be installed either on odroid or Physical/Virtual machine, in this step we need to determine hardware. If script runs on odroid it should find Processor = ARM Hardware = XU3 or XU4 or C1+ or C2 If script runs on Physical/Virtual machine it should fine Processor = Intel After determining hardware type we can determine the next step.
If hardware is Physical/Virtual machine

 - Step 4. Checking requirements
There are a list of minimum requirements that Physical/Virtual machine needs to meet.
    2 network interfaces (ethernet or wlan)
    1 GB of Physical memory
    16 GB of Free disk space
If machine meets the requirements then script goes to next step, otherwise it will warn and exit.

 - Step 5. Getting DHCP client on interfaces
In this step script first DHCP request from eth1 to get an ip address. If succeed, it will check for Internet connection and if Internet connection is established this step is done successfully. In any case of failure (no DHCP response or on Internet connection) script will try the same scenario for next interface. Order to try is - eth1, wlan1, eth0, wlan0 (list of available interfaces are available from step 4).
Of no success in any interface, then script will warn user to plug the machine to Internet and will exit.

 - Step 6. Preparing repositories and updating sources
In this step script adds repository links for necessary packages into package manager sources and updates them. Script will output an error ant exit if it is not possible to add repositories or update sources.

 - Step 7. Downloading and Installing packages
As we already have repository sources updated in step 6, so at this point script will download and install packages using package manager tools. If something goes wrong during download or installation, script will output an error ant exit.
If step 7 finished successfully then test.sh execution for Physical/Virtual machine is finished successfully and it's time to run the next script “app-installation-script.sh”.
If hardware is odroid board

 - Step 4.2. Check if the board assembled.
There are list of modules that need to be connected to odroid board, so script will check if that modules are connected.
You can fine information about necessary modules here
If any module is missed user will get warning and script will exit.

 - Step 5.2. Configuring bridge interfaces.
In this step script will configure 2 bridge interfaces br0 and br1.
    eth0 and wlan0 will be bridged into interface br0
    eth1 and wlan1 will be bridged into interface br1
In ethernet network, br0 should be connected to Internet and br0 to local network. In wireless network, bridge interdace with wore powerful wlan will be connected to Internet and other one to local network.
After configuring bridge interfaces script will enable dhcp chient on external network interface and set static ip address 10.0.0.1/8 in internal network interface, and then check the Internet connection.
If everything goes fine it will process to next step, otherwise will warn the user to plug the machine to Internet and exit.

 - Step 6.2. Preparing repositories and updating sources
The same as in Physical/Virtual machine case.

 - Step 7.2. Downloading and Installing packages
The same as in Physical/Virtual machine case.
If step 7 finished successfully then test.sh execution for odroid board is finished successfully and it's time to run the next script “app-installation-script.sh”. 

 - Step 8 Required (not implemented)
Setup the proper exit for the script with a proper succes or not
Success need to be based in a list check for all apps has being installed.
 



#app-configuration-script.sh (Parametrization script)**

It aims to configure all the packages and services.

![configuration_script_](https://cloud.githubusercontent.com/assets/18449119/17086028/edfbbd78-51e7-11e6-996f-e67e849a88a0.JPG)

1. Check User 
  * You need to run script as root user

2. Get variables
  * Get variables values defined by app-installation-script.sh

3. Configure network interfaces
  * External interface will be configured to get ip dinamically 
  * Internal interface will be configured with static ip address 10.0.0.1/24
  There are also 4 virtual interfaces
  * :1 10.0.0.251/24 for Yacy services
  * :2 10.0.0.252/24 for Friendica services
  * :3 10.0.0.253/24 for Owncloud services 
  * :4 10.0.0.254/24 for Mailpile services

David Need to describe with a diagram what is in here:

 https://raw.githubusercontent.com/Librerouter/Librekernel/gh-pages/app-configuration-script.sh




This project is licensed under the terms of the **GNU GPL V2** license.


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#functional-specs
To be specified
This section can have functional specifications for this project. It can list
specifications like follows:
Configurable user privacy settings
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#architecture
To be specified
This section can have detailed architecture of the project. Along with that it
can explain the different technical blocks involved in the project.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#roadmap
To be specified
Features to be implemented in the project to be listed here in order of priority
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##***Blob Example***
	- add example here
	
##***FAQ***
	
	Q. Can you define the project in a line here?
	-> An end user privacy firewall

	Q. Are there any other similar projects?
	-> Sure there are

	Q. Is their any demo showing that it is actually doing what is being claimed?
	-> Work-in-progress


**Following sections need to be placed at appropriate places**

*** Section 2**
Kernel & Forensics
Threat 	CageOS Protection
Several Exploit 	GrSecurity
Memory-based protection schemes 	PaX
Mandatory access control scheme 	SELinux
Cold Boot Attack 	TRESOR
Potentially hostile/injected code from non-code containing memory pages 	KERNEXEC
System
Threat 	CageOS Protection
Toolchain compilation (fortify) 	libc patches
MAC Spoof 	MAC Address randomizer
Hardware Serial number identification 	HDD/RAM serial number changer
Vulnerable on bootloader 	Bootloader password protection
Vulnerable on boot partition modifications 	/boot partition Read only. Needed to change only on kernel upgrades
SSH root login directly 	Disable SSH root login
Physical reboot 	Disable control+alt+del on inittab & /​etc/​acpi/​powerbtn-acpi-support.sh
Brute force attack on services 	Fail2Ban
ICMP Flood Protection 	IPTables not answer ICMP requests
Network accept all port connection 	IPTables DROP policy by default
Virus infection on other network OS 	Clamav
Intrusion Detection System 	Suricata
Hidden software exploits 	RKHunter
Software security holes 	Debian Security repositories
Untrusted Cronjobs 	Block cronjobs for everybody in cron.deny
Binaries with root permission 	Disable unwanted SUID/SGID binaries
Insecure network programs 	Block rlogink,telnet,tftp,ftp,rsh,rexec
IP spoof 	sysctl hardening configuration
IP spoof 	Darknet preconfigure
TOR extra security 	SocksPort 9050 IsolateClientAddr IsolateSOCKSAuth IsolateClientProtocol IsolateDestPort IsolateDestAddr
DNS leak protection 	Usage of OpenNIC
Hidden code on apps 	Verifiable builds
Take advantage of already logged in sessions 	Bash usage of VLOCK and/or TMOUT to protect your bash login
Direct access to HDD data 	Full disk LUKS encryption
Exploits of shared resources & hardware 	Docker
SSH Old protocol weak 	SSH only protocol V2 allowed
Computer stealing 	Secured&encrypted backup on decentralized storage grid
Rootkit 	Use OpenSource & RKHunter
Software backdoor 	Use OpenSource
Hardware backdoor 	Use OpenHardware
Packet Sniffing 	Using HTTPS Everywhere
Security
Responsible for building Tor circuits 	Tor client running on Librerouter
Exploit Quantum protection 	Yes, suricata
Intrusion Prevention System 	Yes
Browser exploit protection 	Yes
Protection against IP/location discovery 	Yes & agent
Workstation does not have to trust Gateway 	No
IP/DNS protocol leak protection 	Only if you configure manually
Updates
Operating System Updates 	Persist once updated
Update Notifications 	Yes on LED and TFT display
Important news notifications 	Yes on LED and TFT display
Decentralized System Updates 	Using APT P2P
Fingerprint
Network/web Fingerprint 	Maximum possible protection with Agent (pc (windows/linux/mac) & mobile (android/ios)
Clearnet traffic 	Routing model it's described in Network page
Surf the deepweb with regular browser 	Yes but not recommended
Randomized update notifications 	Yes
Privacy Enhanced Browser 	Yes, Tor Browser with patches
Hides your time zone (set to UTC) 	Yes
Secure gpg.conf 	Yes
Enable secure SSH access 	Yes, through physical TFT with external network disconnect
Auto Disable logins 	Only logins are possible on configuration mode, activated through physical TFT with external network disconnect
Internet of the Things protection 	Yes, it's described in Network page
Misc
HTTP Header Anonymous 	Yes
Big clock skew attack against NTP 	Tot blocked
VPN Support 	Configurable through TFT
Ad-bloking track protection 	Yes
Root password configuration 	Yes, mandatory on first boot and later on TFT configuration panel
Wifi password configuratio 	Yes, manadatory on first boot and later on TFT configuration panel
Internal WIFI device without password or WPA encryption 

