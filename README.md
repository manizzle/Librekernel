![librerouter - logo](https://cloud.githubusercontent.com/assets/13025157/14472862/85e49ae0-00f5-11e6-9591-163f1acd5098.png)

---------

&nbsp;



- [Introduction](#introduction)
	- [FAQ] (#faq)
	- [Why we need this technology?] (#why-do-we-need-this-technology)
	- [What is linux libre?](#what-is-linux-libre)
	- [What intend to be librouter?](#what-intend-to-be-librerouter)
	- [Who? Why? What? How?](#who-why-what-how)
	- [What is open source hardware?](#what-is-open-source-hardware)
	- [Which are the licenses and certifications that show openness in the hardware?](#which-are-the-licenses-and-certifications-that-show-openness-in-the-hardware)
	- [Which are the certifications for privacy and security?](#which-are-the-certifications-for-privacy-and-security)
	- [Which are security product certifications?](#which-are-security-product-certifications)
	- [Purposed Operating Systems](#purposed-operating-systems)
- [Technical Overview](#technical-overview)
	- [How to use Librerouter in Hardware?](#how-to-use-librerouter-in-hardware)
	- [Which hardware is needed to run Librerouter?](#which-hardware-is-needed-to-run-librerouter?)
	- [Services are running in Librerouter](#services-are-running-in-librouter)
- [Functional Specification](#functional-specs)
- [Installation and Setup](#installation-and-setup)
	- [Prerequisites](#prerequisites)
	
- [Roadmap](#roadmap)
- [To be categorized](#others)

#Introduction



##***FAQ***
	
	Q. Can you define the project in a line here?
	-> An end user privacy firewall

	Q. Are there any other similar projects?
	-> Sure there are

	Q. Is their any demo showing that it is actually doing what is being claimed?
	-> Work-in-progress


##***Why do we need this technology?***

- **Sniffers**: those that are checking your traffic.
- **Government spy/monitoring institutions passive actions**: collecting general data from worldwide.
- **Librerouter evil nodes**:  a box Owned for those _bad people_.
- **Malicious internet nodes**: better known as _blackbones_.
- **Your internet provider (ISP)**: if they would trying anything with your data.

##***What is Linux-libre?***

Is an operating system kernel and a GNU package[3] that is maintained from modified versions of the Linux kernel. The aim of the project is to remove from the Linux kernel any software that does not include its source code, has its source code obfuscated, or is released under proprietary licenses.

Software components with no available source code are called binary blobs and, as such, are mostly used for proprietary firmware images in the Linux kernel. While generally redistributable, binary blobs do not give the user the freedom to audit, modify or, consequently, redistribute their modified versions.

####***3 ways to have Linux with no blobs:***
- **Deblobing** : clean up and verify linux tarballs and patches for non-Free blobs, you can check if your linux tarballs has non-free blobs or not from [here](http://www.fsfla.org/svn/fsfla/software/linux-libre/scripts/deblob-check)
- Use clean basement and dont allow instaltion of 3rd party software that is stablished by trust control is free of blobls. Example [linux libre](http://www.linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-4.6.N/)
- **VRMS**: VRMS(Virtual Richard M. Stallman) is a program that analyzes the set of currently-installed packages on a Debian-based system, and reports all of the packages from the non-free tree which are currently installed. Software gets placed in the non-free tree when it is agreed not to be too problematic for Debian to distribute but does not meet the Debian Free Software Guidelines and therefore cannot be included in their official distribution. For each program from "non-free" installed, vrms displays an explanation of why it is non-free, if one is available.:https://alioth.debian.org/projects/vrms/

#####***Philosophically speaking, you could consider the difference to be as follows:***

- The Debian kernel doesn't include any non-free firmware (bugs aside), but it allows users to load non-free firmware if they wish to do so.

- The Linux-libre kernel doesn't include any non-free firmware or anything looking like firmware, and it prevents users from loading non-free firmware even if they wish to do so.

#####***Linux-libre is built by running a deblob script on the kernel source code. This goes through the kernel source code, and makes various firmware-related changes:***

- Any firmware for which source code is available is preserved, but the script makes sure the source code is available.
- Any module requiring firmware is stripped of the ability to load the firmware.
- Any source code which looks like firmware (sequences of numbers) is removed.
- Any file containing only firmware (e.g. the contents of firmware/radeon) is removed.

##***What intend to be Librerouter?***
GNU open hardware running and GNU software:

##***Who? Why? What? How?***

A unique combination of open hardware or audited, GNU software and trainning you can achieve **a decrease** of the cyber risks:

- Open source comunity.
- Solution to bypass censorship, spy agencies, anti net neutrality internet providers, and gov. control.
- Easy to use for all people with zero tech knowledge.
- Plug and play system to make your traffic untraceable.
- It is the future Data Center resilience infrastructure.

##***What is open source hardware?***

It consists of physical artifacts of technology designed and offered by the open design movement. Both free and open-source software (FOSS) as well as open-source hardware is created by this open-source culture movement and applies a like concept to a variety of components. It is sometimes, thus, referred to as FOSH (free and open-source hardware). The term usually means that information about the hardware is easily discerned so that others can make it - coupling it closely to the maker movement.[1] Hardware design (i.e. mechanical drawings, schematics, bills of material, PCB layout data, HDL source code[2] and integrated circuit layout data), in addition to the software that drives the hardware, are all released under free/libre terms. The original sharer gains feedback and potentially improvements on the design from the FOSH community. There is now significant evidence that such sharing can drive a high return on investment for investors.


###***LGPL***

The GNU Lesser General Public License (LGPL) is a free software license published by the Free Software Foundation (FSF). The license allows developers and companies to use and integrate software released under the LGPL into their own (even proprietary) software without being required by the terms of a strong copyleft license to release the source code of their own components. The license only requires software under the LGPL be modifiable by end users via source code availability. For proprietary software, code under the LGPL is usually used in the form of a shared library such as a DLL, so that there is a clear separation between the proprietary and LGPL components. The LGPL is primarily used for software libraries, although it is also used by some stand-alone applications.

###***CC***

A Creative Commons (CC) license is one of several public copyright licenses that enable the free distribution of an otherwise copyrighted work. A CC license is used when an author wants to give people the right to share, use, and build upon a work that they have created. CC provides an author flexibility (for example, they might choose to allow only non-commercial uses of their own work) and protects the people who use or redistribute an author's work from concerns of copyright infringement as long as they abide by the conditions that are specified in the license by which the author distributes the work.

###***Many H/W providers claimed they produce open hardware but it's just crap?***

The market is full of crowdfunded project where the funder claimed the project is open hardware but in real the hardware is full of binary blobls, chipset restringtions and questions about missing parts of info and doc:

- ARM Truszone is a blackbox
- Controllers or Chipset not opensource
- No source code.
- Dark Binaries required.
- No documentation No schematics
- Neeed sign binaries for bein accepted by the board.
- Not accept free booting.

![arm boot tz](https://cloud.githubusercontent.com/assets/17382786/14741525/16a5c3f8-0897-11e6-8b2b-ec1f3fbdc5de.png)

###***Which are the licenses and certifications that show openness in the hardware?***

- http://www.ohwr.org/documents/294
- http://www.gnu.org/licenses/quick-guide-gplv3.en.html
- http://www.tapr.org/OHL
- http://www.opengroup.org/accreditation/o-ttps
- http://www.fsf.org/resources/hw/endorsement/respects-your-freedom

###***Which are the certifications for privacy and security?***

- www.vub.ac.be/LSTS/pub/Dehert/481.pdf
- https://www.truste.com/business-products/dpm-services/
- https://www.european-privacy-seal.eu/EPS-en/Certification
- http://www.iso.org/iso/catalogue_detail.htm?csnumber=61498
- http://www.tuv.com/en/corporate/business_customers/information_security_cw/strategic_information_security/data_protection_certification/data_privacy_certification.html
- http://www.export.gov/safeharbor/
- https://safeharbor.export.gov/swisslist.aspx
- https://www.tuvit.de/en/privacy/uld-privacy-seal-1075.htm
- http://www.prismintl.org/Privacy-Certification/privacy/about-the-privacy-plus-program.html
- https://www.esrb.org/privacy/
- http://www.privacytrust.org/certification/privacy/
- https://www.datenschutzzentrum.de/zertifizierung/
- http://www.edaa.eu/certification-process/trust-seal/

###***Which are security product certifications?***

- http://www.dekra-certification.com/en/cyber-security
- http://www.exsolutiongroup.com/blog/various-types-of-iso-certification-uae-has-to-offer/
- https://digital.premierit.com/all-about-iso-27001-certification
- https://www.apcon.com/apcon-certified-applications?gclid=CMrqsaCTt8wCFcQp0wodJokNQg
- http://www.cyberark.com/awards/
- https://czarsecurities.com/security-seal
- http://www.teletrust.de/en/itsmig/
- https://iapp.org/certify/cipt/
- http://www.cdse.edu/certification/become.html
- https://en.wikipedia.org/wiki/Evaluation_Assurance_Level
- https://en.wikipedia.org/wiki/Common_Criteria
- http://www.asd.gov.au/infosec/aisep/crypto.htm

###***Purposed Operating Systems***

tested only in debian 8.5 x86 32bits 2Gib Ram and 32GB emc

- Debian (after deblobling,hardening,enlight) debian.org
- Lubuntu (after deblobling,hardening,enlight) lubuntu.org
- Ubuntu Core NUC (after deblobling) https://developer.ubuntu.com/en/snappy/start/intel-nuc/
- Devuan (librekernel,(after apply hardening) https://devuan.org/  do not boot in Pipo
- Uruk   (librekernel),(after apply hardening) https://urukproject.org//dist/index.html
- LibreWRT (librekernel)
- FreeBSD (librekernel) complex
- Dockers (further containerization for security) (reference qubeOS.org)

#Technical Overview

###***How to connect to use Librerouter in Hardware?***

From inside secureLAN

![from home](https://cloud.githubusercontent.com/assets/13025157/14445987/c112aa48-0051-11e6-907d-dcbe9cc77805.png)

From being routed through any Darknet 

![from outdoor](https://cloud.githubusercontent.com/assets/13025157/14445989/c1160490-0051-11e6-9996-bc6ffe9386f1.png)


###***How it will protect me?***

- With our bridge, a secured open operating system when we would have the hardened version of it (initially based debian libre)

![mempo](https://cloud.githubusercontent.com/assets/17382786/17207306/48017294-54b4-11e6-8d6e-d50e66288416.png)

- Decentralizing the services you consume from the cloud at local alternatives (making impossible to apply big data enemy corps.)
- Anonymous web traffic enforcer Ad-blocker, intrusion prevention system, anti-virus and anti-tracking technology for your web - browsing. Filtering virus, exploits, malware, ads , bad reputational IP and tasteless content.
- Selfhosted obfuscated authentication (dissolve legal relation between user-human and legal-name), 
- Forcing encryption in transport and in rest data.
- Decentralization of auth https://cageos.org/index.php?page=apps&section=Autenticacion
- Network filtering the MetaData that expose you, like scripts,cookies, browser info, docs meta, etc. 
![metapollas](https://cloud.githubusercontent.com/assets/13025157/14502287/d6467f16-01aa-11e6-91d3-5e757c73a626.jpg)
![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)
![softwarelist](https://cloud.githubusercontent.com/assets/13025157/14445470/7411e258-004d-11e6-8447-2e2f554ca756.jpg)
![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)

#***Services are running in Librerouter***

![servicecomparison](https://cloud.githubusercontent.com/assets/13025157/14443209/0a778136-003e-11e6-98dc-5a699933e7f6.jpg)

|App|Decentralized|AnonymInsid|Ncryptclientside|Ncryptservrside|PubPrivF2F|ExposepubIP|
|:---|:---|:---|:---|:---|:---|:---|
|OwnCloud|Yes|No|No|Yes|PrivtFederation|Yes|
|Mailpile|Yes|No|4096DSAelg|No|Private|Yes|
|Rouncube|Yes|No|4096DSAelg|No|Private|Yes|
|Diaspora|Yes|No|No|EncFS|Public|Yes|
|Friendica|yes|not|not|EncFS|Public|yes|
|YaCy|Yes|No|EncFS|Public|Yes|No|
|TahoeI2p|Yes|Yes|Yes|owncloud|Public|No|
|ProsodyTOR|Yes|No|Yes|No|Public|No|
|RTCio|Yes|No|Partially|No|Public|Yes|
|TOR|No|Yes|No|May Be|Public|No|
|I2P|Yes|Yes|No|Yes|Private|Yes|
|Dovecot|Yes|No|?|Public|Yes|No|
|Postfix|Yes|No|?|Public|Yes|No|
|:---|:---|:---|:---|:---|:---|:---|

- Decentrazied collaboration and makerplaces

https://cageos.org/index.php?page=apps&section=Collaborative
https://openbazaar.org

- A decentralized anonymous Search Engine with admin rights.
- 
![data center or decent-ralization](https://cloud.githubusercontent.com/assets/13025157/14444635/1047009c-0047-11e6-89a2-b271457d9df7.png)

![search engine](https://cloud.githubusercontent.com/assets/13025157/14445495/ac8eeeb4-004d-11e6-92c0-89fdc5c8cbb4.jpg)

https://cageos.org/index.php?page=apps&section=SearchEngine

- A filter-connector for your Social Networks in one single place using decentralized social network Friendica.

https://cageos.org/index.php?page=apps&section=SocialNetworks

![socialnetworks](https://cloud.githubusercontent.com/assets/13025157/14444852/be938994-0048-11e6-9200-0299ac312b3b.jpg)

- Secure decentralized video conferences based in XMPPoverTOR or WebRTC.
- 
https://cageos.org/index.php?page=apps&section=Collaborative

![rtcio](https://cloud.githubusercontent.com/assets/13025157/14445429/3081fd8e-004d-11e6-893f-8a4b4ccc9c1e.jpg)


- A secure Storage System with collaborative tools based in : TahoeLafs over i2P and blocksnet.

https://cageos.org/index.php?page=apps&section=StorageOwnCloud

https://cageos.org/index.php?page=apps&section=DecentralizedBackup

- Transparent Email encryption for your actual email.
- 
https://cageos.org/index.php?page=apps&section=SecureEmail

![email](https://cloud.githubusercontent.com/assets/13025157/14445983/c101a78e-0051-11e6-9efc-35569cf73c04.jpg)

## Service The descentralized Social networkNetwork

Librerouter can act as a unified entry and outgoing point for all of your posts across social networks, as well as a filter for what is important to you.For example, do you hate cat videos? (Really? Can I get you some help?)
You can use Librerouter to filter them out when it automatically imports posts from Facebook, Twitter, and Pinterest!
You control your incoming and outgoing posts, and push your posts from a single place to everywhere with no need to open each social network in a separate tab.We aren’t asking you to give up on social media.Instead we offer you a way to be in the captain’s chair.

## Service The descentralized Video Conference

With federated XMPP servers for authentication but perfect for discovering users outside the Librerouter network with security from the normal web.  
Unauthenticated and decentralized web browser video conferencing through anonymous links to create fast video conference rooms without third parties or middlemen involved.

##Service Descentralized Indestructible Storage the RockStar app

Imagine all the important information you have stored on the hard drive of your computer.You are just one hardware failure away from disaster.After all, when did you do your last backup? Unfortunately, centralized storage solutions such as Dropbox and Google Drive also present a variety of risks:

• Data kidnapping: A real example was Mega. (FBI closed it in 2009). 
• Disaster: Your external hard disks fail or stolen. (no disaster recovery)   
• Privacy: You're at risk of having your data hacked and stolen if it’s not encrypted.

![gridstorage](https://cloud.githubusercontent.com/assets/13025157/14445990/c11a4172-0051-11e6-93f8-23a53225b479.jpg)

The decentralized (i2p) version of Tahoe LAFS-Grid (with protections against Sybil attacks and upload Dodos) is a new way to make your data indestructible. A grid splits your files up into little pieces, encrypts them and spreads them out geographically, making it immune to any disaster or service outage.
In our decentralized system your valuable information is encrypted three times:
1. Before it even leaves your computer, in the web browser
2. In the collaboration tool before the data goes to the hard disk
3. When backing up to the grid, the slices will also be encrypted. 
4. 
![tahoe](https://cloud.githubusercontent.com/assets/13025157/14444761/fea4bc0c-0047-11e6-80bd-583bcb7b0fda.jpg)

The decentralized (i2p) version of Tahoe LAFS-Grid (with protections against Sybil attacks and upload Dodos) is a new way to make your data indestructible. 

![storage](https://cloud.githubusercontent.com/assets/13025157/14444754/f0ebf814-0047-11e6-9558-25e26b3d614b.jpg)

A grid splits your files up into little pieces, encrypts them and spreads them out geographically, making it immune to any disaster or service outage.

![grid](https://cloud.githubusercontent.com/assets/13025157/14444751/e3eaba38-0047-11e6-95f4-e4753c0d50c5.jpg)

![grid4](https://cloud.githubusercontent.com/assets/13025157/14444809/5f670ebe-0048-11e6-8b0d-5170ab2afdc4.png)

You can also sync your home Librerouter with all of your portable devices to have the same files and receive the same alerts in real time.If someone steals your cube or for some reason it is destroyed, you can simply buy a replacement Librerouter server and recover your lost data automatically from the Grid.In minutes you’re up and running again!

![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)

Libraries:
https://213.129.164.215:4580/dokuwiki/doku.php?id=technical:software:matrix:featurescomparison

![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)


#Setting up a lab:

You would need to setup 2 machines like this:

![deded](https://cloud.githubusercontent.com/assets/17382786/17208311/782c6d8a-54b8-11e6-82b7-e408db4f966d.png)

One is a Debian where you will do a Virtual Machine Snapshoot BEFORE! installing the in YOUR Debian LFS the Librerouter Scripts

The other VirtualMachine could be a privacyshit like windows 10 or simillar conected to the internal interface of the Librerouter.

![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)

##1. Setup Librerouter software Virtual machine 

You need Debian 8.5 32bits

Ongoing further: Devuan,Lubuntu/Core,Uruk,Dockers, Librewrt

##2. Seting up in Pipo X8-9-10.

PIPO Intel NUC Z8083 is NOT! open hardware/source because the boot is NOT able to support yet replacement with Coreboot or Uboot
Due to limitations: Only PRE-sold 300 boxes in crowdfunding, we can NOT go prod with ARM-FPGA boards plus screen in case, its too expensive)

![infografia_12](https://cloud.githubusercontent.com/assets/13025157/16766793/67d0bb0e-483c-11e6-99ad-9b6ccf856e1a.jpg)

Pipo do not have 1Tb HDD or 2 ethernets or 2 wlans, the version we test has addiotional components.
The Debian LFromScratch will contain drivers that may be restrictive, again if you want a 100% open the you need fpga/arm boards in the market for router compatible with debian. 
![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)
![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)

We plan to dev in to the next presented hreally open hardware when is fully ready but for now the test is customized PIPO

![pismasher_sbc](https://cloud.githubusercontent.com/assets/17382786/17208572/96313d46-54b9-11e6-99e0-ee4018a90a92.jpg)

http://dab-embedded.com/en/cases/openwrt-atmel-sama5d3-and-max10-fpga-board/

![owtbrd](https://cloud.githubusercontent.com/assets/17382786/17208817/7400644e-54ba-11e6-8607-2347be8de41a.png)

Or you can buy expensive board like this one:

![clearfog_pro_openwrt_router_board](https://cloud.githubusercontent.com/assets/17382786/17208844/90b919c8-54ba-11e6-928a-c07c732d25b6.jpg)

https://www.solid-run.com/product-category/clearfog-carriers/


We still in research about this cheap Clearfog boards. Keep you posted.


![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)
![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)
![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)


#Installation and Setup

###***Which hardware/Virtual resources you needed to run Librerouter scripts?***

Anyone able to run a Debian 8.5  ARM,x86 or 64 bits 

- At least 2 network interfaces NICS (external and internal always no matters bridge or server mode),
- 2GB RAM
- 4 cores CPU 
- 1TB Hdd. or 32GBemc


###***The way networking works in Librerouter will be as follows:

- There are two bridges with two interfaces each in PIPO in VM you dont have bridges (only 2 separated zone NICs):
	
1. External area red bridge acting as WAN (2 nics): cable or wireless interface as DHCP client of your internet router
2. Internal area gren bridge acting as LAN (2 nics): cable or wireless interface as an AP for being DHCP server for your new secure LAN.

- Four possible PHySICAL scenarios:
![cable or wifi](https://cloud.githubusercontent.com/assets/13025157/14445978/c0e3a824-0051-11e6-9b69-aeca8d572b2e.png)
 - WAN is WiFi, LAN is WiFi
 - WAN is WiFi, LAN is Cabled Ethernet
 - WAN is Cabled Ethernet, LAN is WiFi
 - WAN is Cabled Ethernet, LAN is Cabled Ethernet

**Step 2: Setup the network.**

Librerouter has two way to work: 

 - Server (no protection but services)
 - Network Router (services and network protection) (dont mix with NIC bridges that we have to separate 4 interfaces in 2 zones)
 

##Steps to setup on Physical/Virtual machine.


##Server mode

The way networking works in Librerouter will be:

 -  Fix serviceable IPs in 10.0.0.x can be wireless or Cabled Ethernet connected to the existing internet router LAN. 
 -  Server mode with both WAN and LAN interfaces in the same DMZ or VLAN or area and not threating the network traffic (not hable to defend against web browsing leaks,tracking,ads and malware)

![untitled](https://cloud.githubusercontent.com/assets/17382786/17251287/588b1aa8-55a8-11e6-9c07-3ccca07a560a.png)
![untitled](https://cloud.githubusercontent.com/assets/17382786/17251155/d6e66fca-55a7-11e6-910d-4c8769bb57ab.png)
![server](https://cloud.githubusercontent.com/assets/13025157/14443924/9c798300-0042-11e6-85b1-1760c5b3789d.png)
![servermodeworkflow](https://cloud.githubusercontent.com/assets/13025157/14444317/f69f0ec0-0044-11e6-9c94-ad7a9c496140.png)

 
##Router mode

Where the trafic is filtered by dns , by ip via iptables, by protocol, application layer signature and reputationally. 

![bridge](https://cloud.githubusercontent.com/assets/13025157/14443871/4bf91bfc-0042-11e6-9ca5-06a23891d32e.png)
##Menu GUI later on (check GUI md doc in this repository)
![bridmode workflow](https://cloud.githubusercontent.com/assets/130157/14444156/373281de-0044-11e6-9d3d-6c536c0b3844.png)



#Network Working flow 

Pending Update l7f and others

![networktraffic6](https://cloud.githubusercontent.com/assets/13025157/14437535/f40d21c4-0021-11e6-9e4a-1c73e06e965b.png)



Pending here arquitecture of unbound,iptables,squid,etc all chain


###Connection Flow 3: Squid Open SSL Tunnel

When user it's using a HTTPS connection to a darknet domain, this traffic it's considered as insecure.
On darknet domains, squid will open the SSL tunnel and inspect for possible exploits, virus and attacks to the user.
If this connection it's to a HTTPS regular domain, this SSL tunnel will be not open nor inspected. Will be routed directly to the internet (ex: https://yourbank.com)

###Connection Flow 4: Squid Content Filtering Virus & Anonymous HTTP Headers

Content filtering will be done if it's a HTTPS open SSL tunnel, or a regular HTTP petition.

Squid will do mainly two process of it.

- With I-cmp/clamav plugin, filter all possible viruses.

- Remove from HTTP headers all possible identification to you.
Connection Flow 5: IPS & Exploits: Suricata

If traffic it's a HTTPS open SSL tunnel (only in darknet domains), or a regular HTTP petition, then Suricata will inspect traffic, too.

Suricata will be configured with rules to avoid, mainly, browser exploits (usually in darknets, to take control of browser).

Loading VRT ruleset from snort and other IPS.

Connection Flow 6: Connection to Outside

If connection pass all blocks and Connection Flow filters, then this petition can reach the internet. Otherwise will be blocked. And will reach in this way

- I2P domains/eepSite (ex: i2p2.i2p) will be redirected to I2P

- SSL Regular domains (ex: https://yourbank.com) will reach te internet directly (remember no regular connections if you don't allow)

- Hidden services (ex: asdf1234.onion) will go through TOR

- HTTP (ex: http://news.com) will go through TOR to the internet site
Access from outside model (Bypass Router / Closed Ports


#DNS:
##DNS engines:
-used today unbound-dns momentarely( because djdns needs upgrade and it not workeable due to 21july2016  we are searching for developers for it)). 
- If it can not resolved, then we need to ask through TOR if it is not resolved then using DNSCRYPT and using services like D.I.A.N.A (oposite of IANA) or Open NIC.
There are 3 different DNS servers (Unbound Tor and DjDNS) on LibreRouter that work together us one DNS resolution system, to provide the best open source solutions for anonymity and security.  
Here is the list of servers and interfaces/ports DNS servers  are listening.
Unbound is running on 10.0.0.1:53
Tor is running on 10.0.0.1:9053
DjDNS running on 10.0.0.1:8053
At first any DNS request comes to Unbound, which is the main dns server, then if needed unbound will forward the request to Tor or DjDNS. 

##DNS Workflow:

###Classified domains that matched our app decentralized alternatives:
  * Search engines  - will be resolved to ip address 10.0.0.251 (Yacy) by unbound.
  * Social network  - will be resolved to ip address 10.0.0.252 (friendics) by unbound.
  * Online Storage    - Will be resolved to ip address 10.0.0.253 (Owncloud) by unbound.
  * Webmails        - Will be resolved to ip address 10.0.0.254 (MailPile) by unbound.
 If it's a local service (10.0.0.25x) petition it's forwarded to local Nginx server
Step: 1 Classified domains resolution
We have integrated shallalist domains list into unbound, so when DNS request comes at first unbound will check if it’s classified. Classified domain are going to be resolved to local services ip addresses or be blocked.
David describe it from the file perspective of the shalalists files

Here is the list of domains
1.	Chat domains – these domains are going to be resolved to IP address 10.0.0.250. We have WebRTC running on 10.0.0.250, so when you type some chat domain you will get WebRTC in your browser.
2.	Search engines – these domains are going to be resolved to IP address 10.0.0.251 by unbound. We have Yacy running on 10.0.0.251, so when you type some search engine domain you will get Yacy in your browser.
3.	Social networks – these domains are going to be resolved to IP address 10.0.0.252 by unbound. We have Friendica running on 10.0.0.252, so when you type some social network domain you will get Friendica in your browser.
4.	Storage - these domains are going to be resolved to IP address 10.0.0.253 by unbound. We have Owncloud running on 10.0.0.253, so when you type some storage domain you will get Owncloud in your browser.
5.	Webmail - these domains are going to be resolved to IP address 10.0.0.254 by unbound. We have Mailpile running on 10.0.0.254, so when you type some storage domain you will get Mailpile in your browser.

#### Why?
Because if the user make use of centralized webs like Facebook,Google,Dropbox etc, we cant protect his privacy
#### Can I workaround it:
Yes in the future via GUI should be possible to reconfigure this cage.
 ### Darknets Domains
  * .local - will be resolved to local ip address (10.0.0.0/24 network) by unbound.
  * .i2p   - will be resolved to ip address 10.191.0.1 by unbound.
  * .onion - unbound will forward this zone to Tor DNS running on 10.0.0.1:9053
The rest of shadow darknets are coming in the further revisions .
 - Freenet domains:> not yet implemented http://ftp.mirrorservice.org/sites/ftp.wiretapped.net/pub/security/cryptography/apps/freenet/fcptools/linux/gateway.html
- Bit domains> blockchain bitcoin> not yet implemented https://en.wikipedia.org/wiki/Namecoin  https://bit.namecoin.info/

- Zeronet> not yet implemented

- Openbazaar> not yet implemented

- Other decentraized webs> not yet implemented
####onion domains resolution 
If incoming DNS request is for .onion domain then it will be forwarded To Tor DNS server running on 10.0.0.1:9053. Tor DNS server will resolve that request qithin Tor network and resolved ip address will be from 10.192.0.0/16 network.
#### .i2p domains resolution
If incoming DNS request is for .i2p domain then it will be resolved to ip address 10.191.0.1 by unbound.

 ### Other Domains
- Regular webpages (example: www.meneame.net) would need to be resolved by decentralized DNS engine like DjDNS 
![dns](https://cloud.githubusercontent.com/assets/17382786/14493566/5ebfcba6-0186-11e6-9c0d-e6032290dcc0.png)
![part_1_4_dns](https://cloud.githubusercontent.com/assets/17382786/14854168/e37aa830-0c8e-11e6-8ff4-05eddebf200e.png)
![part2_4](https://cloud.githubusercontent.com/assets/17382786/14854169/e39c500c-0c8e-11e6-9802-9b26b951eff5.png)
 
 
###Blocking – this  group includes tracker, redirector, governmental, spyware domains. - these domains are going to be resolved to IP address 10.0.0.1 by unbound. We have Webmin running on 10.0.0.1, so when you type some storage domain you will get Webmin administration interface in your browser to allow/deny given domain
 
Unbound dns  configuration is implemented by configure_unbound() function. (lines 491-726 of app-configuration-script.sh) 
Tor dns configuration is implemented by configure_tor() function. (lines 411-474 of app-configuration-script.sh) 

##Intelligence IP, Domain Providers:
- Shallalist
- mesdk12
- http://urlblacklist.com/?sec=download
- https://www.iblocklist.com/lists
- http://iplists.firehol.org/
- https://github.com/rustybird/corridor
- Spamhaus
- Virustotal











#Step 3. Executing scripts.

In this step you need to download and execute the following scripts on your machine with given order.

 - 0. driver-script-pipoxY.sh pipoX8 or pipox10 plus opendrivers wlan
 - 1. app-installation-script.sh
 - 2. app-configuration-script.sh
 - 3. app-post configuration encryption FDE fill disk en cryption
 - 4. System Wizards
 - 5. Subsystems GUIs for backends forked from IPFIRE

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

 




#Executing scripts.

In this step you need to download and execute the following scripts on your machine with given order.


#Workflow of scripts.

##1. app-installation-script.sh (Initialization script)**

![installation_script2](https://cloud.githubusercontent.com/assets/18449119/17086029/ee2354f0-51e7-11e6-9fbb-0a0764173b94.JPG)


Script workflow

1. Check User 
  * You need to run script as root user

2. Check Platform 
  * Platform should be Debian 7/8, Ubuntu 12.04/14.04, Trisquel 7.0

3. Check Hardware 
  * If you are running this script on odroid it should detect Intel processor

4. Check Requirements (Only for Physical/Virtual machine) 
  * Machine should match the requirements mentioned above

5. Check Internet
  * Check Internet connection

6. Check If Assembled (Only gor LibreRouter)
  * All neccessary modules should be connected to odroid board

7. Configure Bridge Interfaces (Only for LibreRouter)
  * eth0 and wlan0 will be bridged into interface br0
  * eth1 and wlan1 will be bridged into interface br1
  * In ethernet network, br0 should be connected to Internet and br0 to local network
  * In wireless network, bridge interdace with wore powerful wlan will be connected to Internet and other one to local network

8. Prepare perositories
  * Update repositories for necessary packages

9. Download packages
  * Download necessary packages

10. Install packages
  * Install necessary packages

 


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

#FUTURE WIZARDS AND GUIS

This wizard should ask the customer about and is pending in the project to be developed:

 -a) Do you want your protect your privacy or just user Librerouter services? if yes then mode bridge if not then mode equals server.
 -b) Mode Transparent firewall Bridge:
 -     Lets configure the Internet access (WAN)
 -     Do you want to conect your Librerouter to your Internet router via cable or WLAN?
 -         if WLAN
Please specify your internet router SSID Please specify your encryption methods WPA or WPA2 WEP not allowed no encryption not allowed Please specifiy your SSID password The daemon should check the conection getting up If not especify error conditions

if Cable:

*If Cable and DHCP:
Please specify if you would use fix IP or DHCP client? If DHCP Then setup dhcp client in the interface and try to receive IP The daemon should check the conection getting up If not especify error conditions

If Cable and FIX IP address:
*Please provide the IP address Please provide the default GW Please provide the DNS server Trying ping against the IPs If correct finish The daemon should check the conections answers If not especify error conditions

Lets configure the Internal access (LAN Intranet)
 -Do you want to setup your internal protected network via cable or WLAN?

If WLAN then:
 -Please specify your internal new WLAN name SSID Please specifiy your SSID WPA2 CCMP password The daemon should check the connection getting up If not especify error conditions The IP addresses are 10.0.0.1 forced (if the guy another then hack the box)

if Cable then:
 -Please be aware we use this internal range: 10.0.0.100 to 200 Gateway 10.0.0.1 and DNS
 -Please plug a cable Detecting link Link up Now your connected

c) Mode Server only WAN external bridge will be used and then all WLAN and ETH will be all 4 interfaces in the same Bridge NIC logical interface.Do you want to use a cable or want Librerouter connect to your router or switch?

if WLAN

Please specify your internet router SSID Please specify your encryption methods WPA or WPA2 WEP not allowed no encryption not allowed Please specifiy your SSID password The daemon should check the conection getting up If not especify error conditions

if Cable:
If Cable and DHCP:
Please specify if you would use fix IP or DHCP client? If DHCP Then setup dhcp client in the interface and try to receive IP The daemon should check the connection getting up If not specify error conditions

If Cable and FIX IP address:
Please provide the IP address Please provide the default GW Please provide the DNS server Trying ping against the IPs If correct finish The daemon should check the connections answers If not specify error conditions 

mode 2

 Do you want to use a cable or want librerouter connect to your router or switch?

if WLAN

Please specify your internet router SSID Please specify your encryption methods WPA or WPA2 WEP not allowed no encryption not allowed Please specifiy your SSID password The daemon should check the conection getting up If not especify error conditions

if Cable:

If Cable and DHCP:

Please specify if you would use fix IP or DHCP client? If DHCP Then setup dhcp client in the interface and try to receive IP The daemon should check the connection getting up If not specify error conditions

If Cable and FIX IP address:

Please provide the IP address Please provide the default GW Please provide the DNS server Trying ping against the IPs If correct finish The daemon should check the connections answers If not specify error conditions 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
There's a first version of Superbrowser for linux 32bit. It's needed to have Java installed

https://cloud.Librerouter.com:8083/public.php?service=files&t=6eacefffe8443befe42af8114988c474

There's a first version of Superbrowser  for windows 32bit. It doens't have I2P network conneciton

https://cloud.Librerouter.com:8083/public.php?service=files&t=8d6e823f6d24dd12605084084299e0fb


The Internet is full of ___free___ services and you are the product they sell your data, in their _terms and conditions page_, that ***almost nobody reads***, and **Librerouter** operates exactly the opposite:

[![4954401_orig](https://cloud.githubusercontent.com/assets/18449119/14941752/a885d1f2-0fa7-11e6-883a-317ceb75aff6.jpg)](https://www.youtube.com/watch?v=yzyafieRcWE)

The below picture of Software Wars is not relevant, it should be deleted
![microsoftempire](https://cloud.githubusercontent.com/assets/17382786/14495567/578ee6e6-0190-11e6-9c93-016a32a56a93.png)
![paranoia](https://cloud.githubusercontent.com/assets/17382786/14495569/57af9850-0190-11e6-9051-9a4ed5977457.png)
![backdoorrouters](https://cloud.githubusercontent.com/assets/17382786/14653063/894a02f6-0677-11e6-9e34-963c0535858d.png)
![netneut](https://cloud.githubusercontent.com/assets/17382786/14496448/800de600-0193-11e6-885e-5537c8714c58.png)
![9dovoix](https://cloud.githubusercontent.com/assets/17382786/17207521/45ba7c00-54b5-11e6-9f6c-f3236f32b9a1.jpg)











































































![milestones](https://cloud.githubusercontent.com/assets/17382786/14495088/46ff610e-018e-11e6-960a-b9725c7f6127.png)
