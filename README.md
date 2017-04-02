![librerouter - logo](https://cloud.githubusercontent.com/assets/13025157/14472862/85e49ae0-00f5-11e6-9591-163f1acd5098.png)

# Setting up the lab in physical:

Suported devices that we need to add a usb to ethernet and 2 atheros wireless network interfaces:

Mini servers:
- Gole1
- Qotom  (recomended)

Any Laptop, PC or server

Tablets:
- Chwi Hi10 or Chwi hi12
- Teclast 
- Onda V919 Air CH
- Teclast X89


# Setting up the lab in Virtual:

ESXi,VirtualBox,other vitrual lab:

- Internet Router<-----eth0----Debian64 latest version----eth1---Virtual Lan vswitch<---ethernet---Windows10
- Internet DHCP server--eth0---Debian64 latest version-----eth1--(debian dhcpserver)--------Win10 (dhcp client)

First of all you should install latest Debian 64bit version in a virtual machine (why Virtual? you can recover fresh install in seconds doing restoration of snapshot):

- 2GB RAM, 2 core procesors, 2NICs (network interfaces)

Second a non privacy friendly OS like Win 10:
- VM requirements in microsoft
- Office 2016
- All possible browsers.dropbox client, seamonkey,firefox,chrome,edge,iexplorer,opera,chromiun.

Hardware resources:

- NIC1 will be NAT/bridged to your Internet dhcp server router.
- NIC2 will be a attached  via virtual switch or vlan to the other VM Windows10. 

From debian to win 10 will be a private LAN in bridge mode. (would require promiscous because arp request from client to server)

You can use any virtualization software you prefer. 

As shown in the following figure.

![deded](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/21.png)

Resume of steps, please be aware that debian should be simplest or non packages should be selected.

- In Virtualbox in debian like: https://jtreminio.com/2012/07/setting-up-a-debian-vm-step-by-step/
- Or any physical machine like https://www.debian.org/doc/manuals/debian-handbook/sect.installation-steps.ru.html
- In the Debian please do a Snapshot in the Virtual machine just after being install.


Important note before testing : 

- Do NOT try to install the scripts via a ssh session. The scripts FAIL if you do that, due to problems with ethernet connection.
- Install the scripts via direct console access.

Go shell command console in debian and execute as root:

(Choose the wget o curl command that you prefer)
- wget -O - http://bit.ly/2gbKstn | bash
or

- wget --no-check-certificate https://raw.githubusercontent.com/Librerouter/Librekernel/gh-pages/setup.sh | bash
or

- apt-get install curl
- curl -L http://bit.ly/2gbKstn | bash


log files are in /var

- apt-get-install-aptth.log
- apt-get-update.log
- apt-get-install_1.log
- apt-get-install_2.log
- apt-get-update-default.log
- libre_install.log
- libre_config.log

### Lab done!

Try to navigate normally from the windows 10.
Report us problems, issues and recomentaditions plus request for features.
Investigate and play while we continue developing it.
New version of the instalaltion-configuration scripts,ISOs and OVA virtual machine export will be upcoming.


## What the setup.sh app-installation-script.sh , app-configuration-script.sh , service.sh and wizard.sh do?

The setup.sh app-installation-script.sh , app-configuration-script.sh , service.sh will be esclusevilly for mounters or assemblers person who mount proffesionall or assemble profesional our products not for the end user. 

setup.sh app-installation-script.sh , app-configuration-script.sh , service.sh requires of plug of physical internet ethernet cable connection.

The end user will be using a USB with auto-installable un-attended ISO image.

Wizard.sh is for the end user and will be maturing and its the first thing the ISO image will be launching.

### 2 future version of the ISO:

- Online: For more profesionals. All is downloaded and compiled.

- Offline Live debian: For non profesional and guided installation.


## Installation workflow:

a) Call setup.sh.

Setup download other scripts and prepare environment. Also reports errors in installacion via centralized repository.(in way to make descentralized).

a.1) Prepare environment
a.2) Replace kernel with libre kernel.
a.3) change sources to not allow non free.

c) App-installation-scrip.sh

App-installation script install all necesary packages. Via different ways: apts,compiling,preparing.
c.1) Tools for filtering
c.2) Server services
c.3) Drivers for open source Wlan devices.

![initial-install-workflow](https://cloud.githubusercontent.com/assets/13025157/14444383/5b99d710-0045-11e6-9ae8-3efa1645f355.png)

d) App-configuration-scrip.sh

App-configuration-script is the real CocaCola maker and in the future will be a encrypted blob, the result will remain be 100% opensource but the way to prepare will be secret. A hacker can duplicate and copy the whole rootfs and distribute it freely. 

e) wizard.sh

Wizard is the initial graphical user interface intendt that we created and will be replaced by a real GUI running in X limited browser.

f) services.sh

It shows up the addresses of your services from clearnet and darknets plus some important data and users.

g) Own development and integration of the opensource.

This already happened and will be increase as investors coming. The only inverstor is a single guy who invested 250k with 300 buyers from Crowdfunding that already losed their faith and patient. (invested 70k netto)


## Networking in Librerouter:

There are two bridges with two interfaces each in the machine like two bridges (only 2 separated zone NICs):
	
1. External area red bridge acting as WAN (2 nics): cable or wireless interface as DHCP client of your internet router.
2. Internal area gren bridge acting as LAN (2 nics): cable or wireless interface as an AP for being DHCP server for your new secure LAN.

## Four possible PHySICAL scenarios:

 - WAN is WiFi, LAN is WiFi
 - WAN is WiFi, LAN is Cabled Ethernet
 - WAN is Cabled Ethernet, LAN is WiFi
 - WAN is Cabled Ethernet, LAN is Cabled Ethernet

## Router bridge mode
![bridgemode](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/38.png)

Where the trafic is filtered by dns , by ip via iptables, by protocol, application layer signature and reputationally. 

![untitled](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/39.png)

![bridmodeworkflow](https://cloud.githubusercontent.com/assets/17382786/17251578/acd2871c-55a9-11e6-9e89-22252735ae39.png)


# How Librerouter will threat the network traffic as a Privacy Firewall in router mode (most common).

![blocking_diagram_1](https://cloud.githubusercontent.com/assets/13025157/18578310/871cd3b2-7bef-11e6-96d2-6b45fd7662e3.png)

 - a) Clean network web browsing traffic (IoT, cookies tracks, scripts tracks, malware, exploits, attackes, non privacy friendly corporations web servers)
 - b) Blocking not privacy friendly protocols and inspecting inside ssl tunnels.
 - c) Monitoring for abnormal behaviours.
 - d) Offering decentralized alternatives of the such called cloud services. 
 - e) Will clean files in storage erasing metadata Sanitization (optional to classified and personal information) 
 - f) Will protect the access to your webs publically in TOR-I2P and clearnet.(normal internet).
 - g) Will selfhost search engine,email,storage,conference,collaborative,git,project managing,socialnetwork, TOR shop.


# Architecture

Still pending to add suricata and modsecurity last changes.

![arch_new](https://cloud.githubusercontent.com/assets/13025157/23234526/a49e2a54-f952-11e6-8042-d5acebbdb757.png)


# Engines especifications and configuration dependencies:

Add here owncloud with excel file.

## OSI STACK FROM DOWN TO UP:

![modsecuritylogo](https://cloud.githubusercontent.com/assets/13025157/24587167/d8d75048-17b1-11e7-951f-41082d321ff6.png)

![modsecuritylogo](https://cloud.githubusercontent.com/assets/13025157/24587367/87779bb4-17b5-11e7-8a9c-baff45b23ba7.png)

## ARP protections

## Layer 3 IP Firewall Iptables configuration.

![protocols policy](https://cloud.githubusercontent.com/assets/13025157/20144114/d6fe682e-a69b-11e6-8036-a0f12e717650.png)

## Layer 4  Iptables NDPI configuration.



## DNS:

- Unbound-dns is the DNS SERVER hsts domain list goes to dns hsts bypass engine. 
- If it is not resolved then using cached then we use DNSCRYPT to ask D.I.A.N.A and OpenNIC.
- If it can not resolved, then we need to ask through TOR aleatory.
- Further integration will include Bitname,others like DjDNS (this last need maintenance is not workinghttps://github.com/DJDNS/djdns)).

![dnsipdate](https://cloud.githubusercontent.com/assets/17382786/17974085/ec54e6b4-6ae4-11e6-9efb-bf2352520459.png)
 
  * Search engines  - will be resolved to ip address 10.0.0.251 (Yacy) by unbound. and hsts downgraded and dns hardredirected.
  * Social network  - will be resolved to ip address 10.0.0.252 (friendics) by unbound. and hsts downgraded and dns hardredirected.
  * Online Storage  - Will be resolved to ip address 10.0.0.253 (Owncloud) by unbound. and hsts downgraded and dns hardredirected.
  * Webmails        - Will be resolved to ip address 10.0.0.254 (MailPile) by unbound. and hsts downgraded and dns hardredirected.
  
![redirection](https://cloud.githubusercontent.com/assets/13025157/20144719/c280abee-a69d-11e6-8af5-cbab5d18d171.png)

### Darknets Domains:
 
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
 

## Can the user in the future workaround the redirection in router mode:

Yes in the future via GUI should be possible to reconfigure this cage enabling services as plugins.



## Suricata Intrusion Prevention System Ruleset versus use cases configuration.

When user is using HTTPS connection to a darknet domain, this traffic it's considered dangerus and insecure. (the goverment try to explodes the browser for deanonymization) On darknet onion and i2p domains, squid will open the SSL tunnel and inspect for possible exploits, virus and attacks to the user.
If this connection it's to a HTTPS regular/banking domain, this SSL tunnel will be not open Bumped/inspected. Will be routed directly to the clearnet internet (ex: https://yourbank.com)

When the user is using HTTP, because is considered insecure itself this clear traffic is going to go through TOR to add anonymization but after a threatment from the local engines to add privacy on it.. The user can also decide in the future about which things he dont want to use TOr for HTTP.
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



## NGINX configuration.

## Modsecurity for Hidenservices and direct clearnet published NAT services

![modsecuritylogo](https://cloud.githubusercontent.com/assets/13025157/24587056/5ab4704e-17af-11e7-99e0-29c50d4acfab.png)



## TOR configurations.
Tor dns configuration is implemented like this...

### Privoxy and Privacy options for TOR traffic:

![privoxy-rulesets-web](https://cloud.githubusercontent.com/assets/17382786/17368067/e269d884-5992-11e6-985c-618b9f5e4c8c.gif)


## I2P configuration.

## Multiple Squids (darknet bumping and clearnet ssl NObump) configurations.

 








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
