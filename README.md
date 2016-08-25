![librerouter - logo](https://cloud.githubusercontent.com/assets/13025157/14472862/85e49ae0-00f5-11e6-9591-163f1acd5098.png)

---------

&nbsp;

##[Index]


- [Overview of Libre Kernel for personal cyber security-privacy](#overview-of-linux-libre-and-libre-kernel-for-personal-cyber-security-and-privacy)
	- [Purpose of this document](#purpose-of-this-document)
	- [Introduction] (#introduction)
	- [Need for this technology] (#need-for-this-technology)
	- [About Linux Libre](#about-linux-libre)
	- [Ways of Proprietary firmware removal and its good effects](#ways-of-proprietary-firmware-removal-and-its-good-effects)
	- [Libre Router Technology](#libre-router-technology)	
	- [Open Source Hardware](#open-source-hardware)
	- [Licenses and certifications available for hardware openness compliance](#licenses-and-certifications-available-for-hardware-openness-compliance)
	- [Certifications available for privacy and security compliance](#certifications-available-for-privacy-and-security-compliance)
	- [Certifications for product security compliance](#certifications-for-product-security-compliance)
	- [Purposed Operating Systems using Linux Libre](#purposed-operating-systems-using-linux-libre)
	- [Technical Overview](#technical-overview)
		- [Using Libre Router to build a secure network](#using-libre-router-to-build-a-secure-network)

		- [How does Libre Router protects us?](#how-does-libre-router-protects-us?)

		- [Services are running in Librerouter](#services-are-running-in-librerouter)

		- [A decentralized anonymous Search Engine with admin rights](#a-decentralized-anonymous-search-engine-with-admin-rights)

		- [Secure decentralized video conferences based in XMPPoverTOR or WebRTC](#secure-decentralized-video-conferences-based-in-xmppovertor-or-webrtc)

		- [Transparent Email encryption for your actual email](#transparent-email-encryption-for-your-actual-email)

		- [Service The descentralized Social network](#service-the-descentralized-social-network)

		- [Service The descentralized Video Conference](#service-the-descentralized-video-conference)

		- [Service Descentralized Indestructible Storage the RockStar app](#service-descentralized-indestructible-storage-the-rockStar-app)




	- [How to use Librerouter in Hardware?](#how-to-use-librerouter-in-hardware)
	- [Which hardware is needed to run Librerouter?](#which-hardware-is-needed-to-run-librerouter?)
	- [Services are running in Librerouter](#services-are-running-in-librouter)
- [Functional Specification](#functional-specs)
- [Installation and Setup](#installation-and-setup)
	- [Prerequisites](#prerequisites)
	
- [Roadmap](#roadmap)
- [FAQ] (#faq)
- [To be categorized](#others)

##***Overview of Linux Libre and Libre Kernel for personal cyber security and privacy***

##***Purpose of this document***

This document is meant to explain the Libre Router linux based open source hardware technologies integrated for creating a secure network for end users to avoid following issues that may happen with or without our explicit or implicit knowledge: 

##***The need for this technology***

	- Traffic Sniffing: those that are checking your traffic: Government spy/monitoring institutions passive actions: collecting general data from worldwide. 
	- Malicious Internet nodes: better known as blackbones. 
	- Your Internet provider (ISP): if they would trying anything with your data like DNS spoofing, traffic shaping, DPI.
	- Back-doors in software (windows friend of NSA) and hardware (Cisco, Huawei,Fortinet,TP-Link) to achieve one or more of the above issues: Control, Spionage, Privacy spooks, politics, police interception, apply bigdata to your cloud for marketing, law enforcement, market research, or simply hacking outbreachs.
	

##Overview of Libre Kernel components:

##***Introduction to what is called Pseudo Backdoor and code (a secret entry door in the program)***

Software components with no available source code are called binary blobs(Binary Large Objects or a collection of binary data stored as a single object) and, as such, are mostly used for proprietary firmware images in the Linux kernel like hard drives, Ethernet, USB controllers, graphic cards etc. Though generally redistributable, binary blobs do not give the user the freedom to review, audit, scrutinize, modify or, consequently, redistribute their modified versions.

[Blob Example](#blob-example)

##***About Linux Libre***

Linux Libre is a free/Libre version of the kernel Linux suitable for use with the GNU Operating System.
It removes non-free components from Linux, that are disguised as source code or distributed in separate files. It also disables run-time requests for non-free components, shipped separately or as part of Linux, and documentation pointing to them. The GNU Linux Libre project takes a minimal-changes approach to cleaning up Linux, making no effort to substitute components that need to be removed with functionally equivalent free/Libre ones.

As explained earlier, its an operating system kernel and a GNU package whose aim is to remove from the Linux kernel any source code with blobs, with obfuscated source code, or is has proprietary licenses.Software components with no available source code are called binary blobs and, as such, are mostly used for proprietary firmware images in the Linux kernel.

##Ways of Proprietary firmware removal and its good effects

1. Deblobing : It is cleaning up and verifying Linux tarballs and patches for non-Free blobs. This is done using the script files deblob-check for verifying the Vanilla Linux kernel tarball for any non-free proprietary, blobs. . Similarly for removing the blobs there is a scripts deblob-* where * represents the Kernel version its tested and applicable for. The script can be found here <http://www.fsfla.org/svn/fsfla/software/linux-libre/scripts/>

2. VRMS(Virtual Richard M. Stallman)
A program that analyzes the set of currently-installed packages on a Debian-based system, and reports all of the packages from the non-free tree which are currently installed. Software gets placed in the non-free tree when it is agreed not to be too problematic for 
Debian to distribute but does not meet the Debian Free Software Guidelines and therefore cannot be included in their official distribution. For each program from "non-free" installed, VRMS displays an explanation of why it is non-free, if one is available. More information about VRMS can be fount at <https://alioth.debian.org/projects/vrms/>

3. Keep the base deblobbed kernel compilation clean:
Use clean basement and don't allow installation of 3rd party software that is established by trust control is free of blobs. For Example for Linux Libre here is the link <http://www.linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-4.6.N/> 

###Kernel

The Linux kernel is a Unix-like computer operating system kernel. The Linux operating system is based on it and deployed on both traditional computer systems such as personal computers and servers, usually in the form of Linux distributions,[9] and on various embedded devices such as routers, wireless access points, PBXes, set-top boxes, FTA receivers, smart TVs, PVRs and NAS appliances. The Android operating system for tablet computers, smartphones and smartwatches is also based atop the Linux kernel.
The Linux kernel was conceived and created in 1991 by Linus Torvalds[10] for his personal computer and with no cross-platform intentions, but has since expanded to support a huge array of computer architectures, many more than other operating systems or kernels

Debian vanilla kernel:
	- Doesn't include any non-free firmware (bugs aside), but it allows users to load non-free 
          firmware if they wish to do so, which might pose the same kind of threats like, Trojans, tracking, 
          kernel training with malicious software, sniffing etc.
	
Linux Libre kernel:
	- The Linux Libre kernel doesn't include any non-free firmware or anything looking like firmware, and it prevents users from loading non-free firmware even if they wish to do so.
	- Is built by running a deblob script on the kernel source code. This goes through the kernel source code, and makes various firmware-related changes. 
	- Any firmware for which source code is available is preserved, but the script makes sure the source code is available. 
	- Any module requiring firmware is stripped of the ability to load the firmware. 
	- Any source code which looks like firmware (sequences of numbers) is removed. 
	- Any file containing only firmware (e.g. the contents of firmware/radeon) is removed. 
	
##Libre Router

In the previous section we talked about Linux Libre which is Linux based operating system kernel and a GNU package.
In this and following few sessions we are going to talk about it's counterpart called LibreRouter which is nothing but a Open Source hardware with no malignant backdoors in the used programs, with source code for kernel logic as well as firmware where Open Source developers will have as much control as possible to bypass the censorship and enforce the security for users.

In simplest term it's a GNU Free and Open Source Hardware (FOSH) running GNU software.

A unique integration of open source hardware by GNU software maintained by Open Source community.
With minimal training and simple documentation you can achieve a decrease cyber risks levels and increase your privacy.
The aim its to make a really very easy to use for all people without computers and networking knowledge also, aim to be simple Plug and play system to make your traffic untraceable and secure. It is the future home and only privacy viable data center infrastructure. 

##Open Source Hardware

It consists of physical artifacts of technology designed and offered by the open design movement. Both free and 
open-source software (FOSS) as well as open-source hardware is created by this open-source culture movement and 
applies a like concept to a variety of components. It is sometimes, thus, referred to as FOSH 
(free and open-source hardware). The term usually means that information about the hardware is easily discerned 
so that others can make it - coupling it closely to the maker movement. Hardware design (i.e. mechanical 
drawings, schematics, bills of material, PCB layout data, HDL source code and integrated circuit layout data), 
in addition to the software that drives the hardware, are all released under free/Libre terms. The original 
sharer gains feedback and potentially improvements on the design from the FOSH community. There is now significant 
evidence that such sharing can drive a high return on investment for investors.

### Licenses for being open

####LGPL (Lesser General Public License):
The GNU Lesser General Public License (LGPL) is a free software license published by the Free Software Foundation (FSF). 
The license allows developers and companies to use and integrate software released under the LGPL into their own 
(even proprietary) software without being required by the terms of a strong copyleft license to release the source 
code of their own components. The license only requires software under the LGPL be modifiable by end users via source 
code availability. For proprietary software, code under the LGPL is usually used in the form of a shared library such 
as a DLL, so that there is a clear separation between the proprietary and LGPL components. The LGPL is primarily used 
for software libraries, although it is also used by some stand-alone applications. please visit <https://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License> 

####CC (Creative Commons) License:
A Creative Commons (CC) license is one of several public copyright licenses that enable the free distribution of 
an otherwise copyrighted work. A CC license is used when an author wants to give people the right to share, use, 
and build upon a work that they have created. CC provides an author flexibility (for example, they might choose 
to allow only non-commercial uses of their own work) and protects the people who use or redistribute an author's 
work from concerns of copyright infringement as long as they abide by the conditions that are specified in the 
license by which the author distributes the work.

###***Hardware openess license and confusing "open" terms***

The market is full of crowdfunded projects where the funders claimed that the project is based in open hardware.
What mostly resulted under a deep research that it requires to operate full range of such called binary blobls (possible backdoor), chipset restringtions (software requires to be signed by the manufacturer) and questions about missing or obfsucated documented parts or schemas/diagrams. The result could be any of this posibilites:

- ARM Truszone is a blackbox (rustZone technology within Cortex-A based application processors is commonly used to run trusted boot and a trusted OS to create a Trusted Execution Environment (TEE). Typical use cases include the protection of authentication mechanisms, cryptography, key material and DRM) As you can imagine this is a big antiopen market mechanism.

- Device drivers=controllers or the chipset could may be not opensource (https://en.wikipedia.org/wiki/Device_driver)
- No source code or the compiler is not opensource
https://en.wikipedia.org/wiki/Source_code 
https://en.wikipedia.org/wiki/Compiler
http://unix.stackexchange.com/questions/89897/how-to-compile-the-c-compiler-from-scratch-then-compile-unix-linux-from-scratch
https://en.wikipedia.org/wiki/Bootstrapping_(compilers)#The_chicken_and_egg_problem
https://en.wikipedia.org/wiki/Bootstrapping_(compilers)
https://www.win.tue.nl/~aeb/linux/hh/thompson/trust.html

- No documentation No schematics on the components of the circuit board.
- Not using free booting boot system. 
https://en.wikipedia.org/wiki/Coreboot 
https://www.phoronix.com/scan.php?page=news_item&px=Coreboot-U-Boot-Payload
![arm boot tz](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/imgg.png)

###***Which are the licenses and certifications that show openness in the hardware?***

- http://www.ohwr.org/documents/294
- http://www.ohwr.org/projects/cernohl/wiki
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

##***How does Libre Router protects us***

Libre router combined with Linux Libre and hardened OS configuration shown above protects us in many ways as follows:
 
	- With our OS, a secured open operating system when we would have the hardened version of it based on 
	  Debian Libre and LFS  https://cageos.org/index.php?page=technical#kernel
	- Decentralizing the services you consume from the cloud at local alternatives (making impossible to 
	  apply big data enemy corps.) 
	- A decentralized anonymous Search Engine with admin rights.  
	- A filter-connector for your Social Networks in one single place using decentralized social network Friendica.
	- Secure decentralized video conferences based in XMPPoverTOR or WebRTC. 
	- A secure Storage System with collaborative tools based in : TahoeLafs over i2P and blocksnet.
	- Transparent Email encryption for your actual email. 
	- Anonymous web traffic enforcer Ad-blocker, intrusion prevention system, anti-virus and anti-tracking technology 
	  for your web - browsing. Filtering virus, exploits, malware, ads , bad reputation IP and tasteless content. 
	- Different services that tract of all the data transaction like Internet proxy, clamav, surikata proxy, snort
          unbound DNS lists, iptables etc
	- Self hosted obfuscated authentication (dissolve legal relation between user-human and legal-name), Forcing         encryption in transport and in rest data.
	- Network filtering the MetaData that expose you, like scripts,cookies, browser info, docs meta, etc.  

Following security pyramid diagram explains the different components that make our network secure.

![mempro](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/6.png)

Following image shows how Libre Router protects by sitting between the outer Internet and out private network

![metapollas](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/13.png)

#Technical Overview

Libre Router use technologies like Free Open Source hardware, Linux Libre, hardened Linux , encryption and many other  to protect the end user or clients agaisnt intrusions, malicious attacks, unwanted advertisements creating a LAN (Local Netwrok area) insside another LAN (your internet router lan)

###***Using Libre Router to build a secure network***

####From inside secureLAN
Imagine your at home, then you use the services locally (local server, local services)

![from home](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/7.png)

From being routed through any Darknet 
Imagine your at work, then you use the services in your home through Darknets (remote server, remote services in TOR, I2P, and others VPNs) In your company its just https traffic so nobody see insside. You can use your personal storage, socialnetwork and everything with security and obscurity. 

![from outdoor](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/10.png)

Following diagram shows the current issues, safeguards against them and the open Source components that help us get rid of it. 

![Issues_Safegaurds](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/14.png)

#***Services are running in Librerouter***

![servicecomparison](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/15.png)

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

#***Decentralized collaboration and makerplaces***

https://cageos.org/index.php?page=apps&section=Collaborative

https://openbazaar.org

#***A decentralized anonymous  Search Engine with admin rights.***

![data center or decent-ralization](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/11-12_v2.png)

![search engine](https://cloud.githubusercontent.com/assets/13025157/14445495/ac8eeeb4-004d-11e6-92c0-89fdc5c8cbb4.jpg)

https://cageos.org/index.php?page=apps&section=SearchEngine

A filter-connector for your Social Networks in one single place using decentralized social network Friendica.

https://cageos.org/index.php?page=apps&section=SocialNetworks

![socialnetworks](https://cloud.githubusercontent.com/assets/13025157/14444852/be938994-0048-11e6-9200-0299ac312b3b.jpg)

#***Secure decentralized video conferences based in XMPPoverTOR or WebRTC.***
- 
https://cageos.org/index.php?page=apps&section=Collaborative

![rtcio](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/8-9_v2.png)


#***A secure Storage System with collaborative tools based in : TahoeLafs over i2P and blocksnet.***

https://cageos.org/index.php?page=apps&section=StorageOwnCloud

https://cageos.org/index.php?page=apps&section=DecentralizedBackup

#***Transparent Email encryption for your actual email.***
- 
https://cageos.org/index.php?page=apps&section=SecureEmail

![email](https://cloud.githubusercontent.com/assets/13025157/14445983/c101a78e-0051-11e6-9efc-35569cf73c04.jpg)

#***Service The descentralized Social networkNetwork***

Librerouter can act as a unified entry and outgoing point for all of your posts across social networks, as well as a filter for what is important to you.For example, do you hate cat videos? (Really? Can I get you some help?)
You can use Librerouter to filter them out when it automatically imports posts from Facebook, Twitter, and Pinterest!
You control your incoming and outgoing posts, and push your posts from a single place to everywhere with no need to open each social network in a separate tab.We aren’t asking you to give up on social media.Instead we offer you a way to be in the captain’s chair.

##Service The descentralized Video Conference

With federated XMPP servers for authentication but perfect for discovering users outside the Librerouter network with security from the normal web.  
Unauthenticated and decentralized web browser video conferencing through anonymous links to create fast video conference rooms without third parties or middlemen involved.

##Service Descentralized Indestructible Storage the RockStar app

Imagine all the important information you have stored on the hard drive of your computer.You are just one hardware failure away from disaster.After all, when did you do your last backup? Unfortunately, centralized storage solutions such as Dropbox and Google Drive also present a variety of risks:

• Data kidnapping: A real example was Mega. (FBI closed it in 2009). 
• Disaster: Your external hard disks fail or stolen. (no disaster recovery)   
• Privacy: You're at risk of having your data hacked and stolen if it’s not encrypted.

![gridstorage](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/16.png)

The decentralized (i2p) version of Tahoe LAFS-Grid (with protections against Sybil attacks and upload Dodos) is a new way to make your data indestructible. A grid splits your files up into little pieces, encrypts them and spreads them out geographically, making it immune to any disaster or service outage.
In our decentralized system your valuable information is encrypted three times:
1. Before it even leaves your computer, in the web browser
2. In the collaboration tool before the data goes to the hard disk
3. When backing up to the grid, the slices will also be encrypted. 

![tahoe](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/17.png)

The decentralized (i2p) version of Tahoe LAFS-Grid (with protections against Sybil attacks and upload Dodos) is a new way to make your data indestructible. 

![storage](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/18-19.jpg)

A grid splits your files up into little pieces, encrypts them and spreads them out geographically, making it immune to any disaster or service outage.

![grid](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/16.png)

![grid4](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/20.png)

You can also sync your home Librerouter with all of your portable devices to have the same files and receive the same alerts in real time.If someone steals your cube or for some reason it is destroyed, you can simply buy a replacement Librerouter server and recover your lost data automatically from the Grid.In minutes you’re up and running again!

Libraries: https://213.129.164.215:4580/dokuwiki/doku.php?id=technical:software:matrix:featurescomparison
https://cageos.org/index.php?page=pilarservices


![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)
![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)

#Setting up a lab:

For Virtual Machine setup we need one system with two guests installed in it, one Debian 8 32 bit and one Windows 10
As shown in the following figure.

![deded](https://github.com/Librerouter/Librekernel/blob/gh-pages/images/21.png)

In the Debian Snapshot we install the Debian Librerouter Scripts.

The other VirtualMachine is windows 10 or simillar conected to the internal interface of the Librerouter.

##1. Setup Librerouter software Virtual machine 

You need Debian 8.5 32bits

Ongoing further: Devuan,Lubuntu/Core,Uruk,Dockers, Librewrt

##2. Seting up in Pipo X8-9-10.

PIPO Intel NUC Z8083 is NOT! open hardware/source because the boot is NOT able to support yet replacement with Coreboot or Uboot
Due to limitations: Only PRE-sold 300 boxes in crowdfunding, we can NOT go prod with ARM-FPGA boards plus screen in case, its too expensive)

Pipo do not have 1Tb HDD or 2 ethernets or 2 wlans, the version we test has addiotional components.
The Debian LFromScratch will contain drivers that may be restrictive, again if you want a 100% open the you need fpga/arm boards in the market for router compatible with debian. 

![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)

We plan to to use open hardware, when is fully ready, but for now, the test is customized PIPO X8-9s-10

We still testing  Clearfog Base board 96$ (no screentouch is possible then the adminGUI need to by direct browser request). 

![xclearfog-base-with-som-01-800x676 jpg pagespeed ic lfn3kzosut](https://cloud.githubusercontent.com/assets/17382786/17366167/17b7d0a8-598a-11e6-8d82-1cd53a57bcb6.jpg)

https://images.solid-build.xyz/A38X/

https://www.solid-run.com/product/clearfog-base/

http://blog.hypriot.com/post/introducing-the-clearfog-pro-router-board/

We'll Keep you posted.

![espacioblanco](https://cloud.githubusercontent.com/assets/17382786/14488687/b41768ba-0169-11e6-96cd-80377e21231d.png)

#***Networking in Librerouter:

- There are two bridges with two interfaces each in PIPO in VM you dont have bridges (only 2 separated zone NICs):
	
1. External area red bridge acting as WAN (2 nics): cable or wireless interface as DHCP client of your internet router.

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
 

##Server mode

The way networking works in Librerouter will be:

 -  Fix serviceable IPs in 10.0.0.x can be wireless or Cabled Ethernet connected to the existing internet router LAN. 
 -  Server mode with both WAN and LAN interfaces in the same DMZ or VLAN or area and not threating the network traffic (not hable to defend against web browsing leaks,tracking,ads and malware)

![untitled](https://cloud.githubusercontent.com/assets/17382786/17251466/3cd5a804-55a9-11e6-883f-2088e8653138.png)

![server](https://cloud.githubusercontent.com/assets/13025157/14443924/9c798300-0042-11e6-85b1-1760c5b3789d.png)

![servermodeworkflow](https://cloud.githubusercontent.com/assets/13025157/14444317/f69f0ec0-0044-11e6-9c94-ad7a9c496140.png)

 
##Router mode

Where the trafic is filtered by dns , by ip via iptables, by protocol, application layer signature and reputationally. 

![untitled](https://cloud.githubusercontent.com/assets/17382786/17251287/588b1aa8-55a8-11e6-9c07-3ccca07a560a.png)

![bridge](https://cloud.githubusercontent.com/assets/13025157/14443871/4bf91bfc-0042-11e6-9ca5-06a23891d32e.png)

![bridmodeworkflow](https://cloud.githubusercontent.com/assets/17382786/17251578/acd2871c-55a9-11e6-9e89-22252735ae39.png)




#Network Working flow 

David to clarify architecture for use cases:

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
 -  m) a guy trying to explode/abuse the local services url -> from hidden services -> so from TOR or I2P how you protect it.
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
a1) webrtc protocol

 
![layers](https://cloud.githubusercontent.com/assets/17382786/17397142/f4f4ba92-5a36-11e6-8721-eddfcc1f18be.png)


![ip use cause](https://cloud.githubusercontent.com/assets/17382786/17254808/a88262ec-55b6-11e6-969d-bfac41e4dadd.png)

![networktraffic6](https://cloud.githubusercontent.com/assets/13025157/14437535/f40d21c4-0021-11e6-9e4a-1c73e06e965b.png)

Technical background for each use case:

##Intelligence IP, Domain Providers:

- Shallalist
- mesdk12 http://squidguard.mesd.k12.or.us/blacklists.tgz
- http://urlblacklist.com/?sec=download
- https://www.iblocklist.com/lists
- http://iplists.firehol.org/
- https://github.com/rustybird/corridor
- Spamhaus
- Virustotal
- http://urlblacklist.com/

##Privacy testers:

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

##Squid Transparent mode interception with IPtables:

 - http://blog.davidvassallo.me/2011/03/22/squid-transparent-ssl-interception/
 - http://wiki.squid-cache.org/SquidFaq/InterceptionProxy
 
##Squid CLAMAV Antivirus:

 - https://sathisharthars.wordpress.com/2013/07/31/configuring-proxy-server-with-antivirus-squidclamavsquidguarddansguardian/

##Squid ADS :

 - https://github.com/jamesmacwhite/squidguard-adblock
 - http://www.squidguard.org/
 - https://calomel.org/squid_adservers.html
 - http://adzapper.sourceforge.net/
 - http://pgl.yoyo.org/adservers/

##Unboudndns ADs:

 - https://github.com/jodrell/unbound-block-hosts

##Squid SSL bumping for AV SSL and IPS (intrusion prevention applied to decrypt traffic) :

 - https://hitch-tls.org/
 - https://github.com/varnish/hitch
 - https://github.com/dani87/sslbump
 - https://github.com/jpelias/squid3-ssl-bump/blob/master/Install%20Squid%203.4%20with%20ssl%20bump%20on%20Debian%208%20(Jessie)
 - https://github.com/diladele

##Squid Content filter with privacy enhacement:

 - https://github.com/e2guardian/e2guardian
 - https://github.com/andybalholm/redwood

##Privoxy and Privacy :

![privoxy-rulesets-web](https://cloud.githubusercontent.com/assets/17382786/17368067/e269d884-5992-11e6-985c-618b9f5e4c8c.gif)


##Squid tuning conf for Privacy :

If you don’t want to use Privoxy you can still set some options in your squid.conf 

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


#NETWORK USE CASES

When user is using HTTPS connection to a darknet domain, this traffic it's considered dangerus and insecure. (the goverment try to explodes the browser for deanonymization) On darknet onion and i2p domains, squid will open the SSL tunnel and inspect for possible exploits, virus and attacks to the user.
If this connection it's to a HTTPS regular/banking domain, this SSL tunnel will be not open Bumped/inspected. Will be routed directly to the clearnet internet (ex: https://yourbank.com)

When the user is using HTTP, because is considered insecure itself this clear traffic is going to go through TOR to add anonymization but after a threatment from the local engines to add privacy on it.. The user can also decide in the future about which things he dont want to use TOr for HTTP.

- I2P domains/eepSite (ex: i2p2.i2p) will be redirected to I2P
- Hidden services (ex: asdf1234.onion) will go through TOR
- HTTP (ex: http://news.com) will go through TOR to the internet site


#DNS:

##DNS engines:
- Used today unbound-dns momentarily ( because djdns needs upgrade and it not workeable due to 21july2016  we are searching for developers for it)). 

- If it can not resolved, then we need to ask through TOR 
- If it is not resolved then using DNSCRYPT and using services like D.I.A.N.A (oposite of IANA) or Open NIC.

X differents DNS servers (Unbound,Tor,I2p,Bitname,others and DjDNS(this last need maintenance is not workinghttps://github.com/DJDNS/djdns)) 

Those need to work together us one DNS resolution system, to provide the best open source solutions for anonymity and security.  
Here is the list of servers and interfaces/ports DNS servers  are listening.

- Unbound is running on 10.0.0.1:53
- Tor is running on 10.0.0.1:9053
- DjDNS running on 10.0.0.1:8053
- Bitname is .....
- Others....



##DNS Workflow:

![dns use cases](https://cloud.githubusercontent.com/assets/17382786/17254117/bc19c140-55b3-11e6-99fc-1b544f3adbd1.png)


###Classified domains that matched our app decentralized alternatives:  If it's a local service (10.0.0.25x) petition it's forwarded to local Nginx server. We have integrated shallalist domains list into unbound, so when DNS request comes at first unbound will check if it’s classified. Classified domain are going to be resolved to local services ip addresses or be blocked.


![part2_4](https://cloud.githubusercontent.com/assets/17382786/14854169/e39c500c-0c8e-11e6-9802-9b26b951eff5.png)
 
 
  * Search engines  - will be resolved to ip address 10.0.0.251 (Yacy) by unbound.
  * Social network  - will be resolved to ip address 10.0.0.252 (friendics) by unbound.
  * Online Storage  - Will be resolved to ip address 10.0.0.253 (Owncloud) by unbound.
  * Webmails        - Will be resolved to ip address 10.0.0.254 (MailPile) by unbound.

#### Darknets Domains
 
  * .local - will be resolved to local ip address (10.0.0.0/24 network) by unbound.
  * .i2p   - will be resolved to ip address 10.191.0.1 by unbound.
  * .onion - unbound will forward this zone to Tor DNS running on 10.0.0.1:9053


![part_1_4_dns](https://cloud.githubusercontent.com/assets/17382786/14854168/e37aa830-0c8e-11e6-8ff4-05eddebf200e.png)


- 	IM domains – these domains are going to be resolved to IP address 10.0.0.250. 
- We have WebRTC running on 10.0.0.250, so when you type some chat domain you will get WebRTC in your browser.

- 	Search engines – these domains are going to be resolved to IP address 10.0.0.251 by unbound. 
- We have Yacy running on 10.0.0.251, so when you type some search engine domain you will get Yacy in your browser.

- 	Social networks – these domains are going to be resolved to IP address 10.0.0.252 by unbound.
- We have Friendica running on 10.0.0.252, so when you type some social network domain you will get Friendica in your browser.

- 	Storage - these domains are going to be resolved to IP address 10.0.0.253 by unbound.
- We have Owncloud running on 10.0.0.253, so when you type some storage domain you will get Owncloud in your browser.
 
- 	Webmail - these domains are going to be resolved to IP address 10.0.0.254 by unbound. 
- We have Mailpile running on 10.0.0.254, so when you type some storage domain you will get Mailpile in your browser.


Still prblems with HSTS https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
Also still problems when a use uses the google/bing search by a direct query in the browser the browser enfoces hsts then the certificate from our redirected yacy fails.


#### Why we try the end user use more fair services than the offered for free (bullshit youll pay entirelife) in internet by some corporations?

Because if the user make use of centralized webs like Facebook,Google,Dropbox etc, we cant protect his privacy and he is going to disclosure himself his data.

#### Can the user in the future workaround it:

Yes in the future via GUI should be possible to reconfigure this cage.

 
More shadow darknets are coming in the further revisions .

- Freenet domains:> not yet implemented
- http://ftp.mirrorservice.org/sites/ftp.wiretapped.net/pub/security/cryptography/apps/freenet/fcptools/linux/gateway.html
- Bit domains> blockchain bitcoin> not yet implemented 
- https://en.wikipedia.org/wiki/Namecoin  https://bit.namecoin.info/
- Zeronet> not yet implemented
- Openbazaar> not yet implemented


 
###Unbounddns server configuration.

- Is implemented by configure_unbound() function. (lines 491-726 of app-configuration-script.sh) 

###TOR configurations.
Tor dns configuration is implemented by configure_tor() function. (lines 411-474 of app-configuration-script.sh) 

###I2P configuration.

###NGINX configuration.

###Multiple Squids (darknet bumping and clearnet ssl NObump) configurations.

###Privoxy configuration.

###Iptables configuration.

###X further service configuration.

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


##Blob Example
Example of a blob from vanilla Linux kernel from Linus that gets distributed on kernel.org
Here is one example from Linux-2.6.24/drivers/net/tg3.c 

--------------------------------------------------------------------------------------------
/*
  * tg3.c: Broadcom Tigon3 ethernet driver.
  *
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@???)
  * Copyright (C) 2001, 2002, 2003 Jeff Garzik (jgarzik@???)
  * Copyright (C) 2004 Sun Microsystems Inc.
  * Copyright (C) 2005-2007 Broadcom Corporation.
  *
  * Firmware is:
  *      Derived from proprietary unpublished source code,
  *      Copyright (C) 2000-2003 Broadcom Corporation.
  *
  *      Permission is hereby granted for the distribution of this firmware
  *      data in hexadecimal or equivalent format, provided this copyright
  *      notice is accompanying it.
  */



It then has screenfulls of non-free code like this: 

0x0e000003, 0x00000000, 0x08001b24, 0x00000000, 0x10000003, 0x00000000, 
0x0000000d, 0x0000000d, 0x3c1d0800, 0x37bd4000, 0x03a0f021, 0x3c100800, 
0x26100000, 0x0e000010, 0x00000000, 0x0000000d, 0x27bdffe0, 0x3c04fefe, 
0xafbf0018, 0x0e0005d8, 0x34840002, 0x0e000668, 0x00000000, 0x3c030800, 
0x90631b68, 0x24020002, 0x3c040800, 0x24841aac, 0x14620003, 0x24050001, 
0x3c040800, 0x24841aa0, 0x24060006, 0x00003821, 0xafa00010, 0x0e00067c, 
0xafa00014, 0x8f625c50, 0x34420001, 0xaf625c50, 0x8f625c90, 0x34420001, 
0xaf625c90, 0x2402ffff, 0x0e000034, 0xaf625404, 0x8fbf0018, 0x03e00008, 
0x27bd0020, 0x00000000, 0x00000000, 0x00000000, 0x27bdffe0, 0xafbf001c, 
0xafb20018, 0xafb10014, 0x0e00005b, 0xafb00010, 0x24120002, 0x24110001, 
0x8f706820, 0x32020100, 0x10400003, 0x00000000, 0x0e0000bb, 0x00000000, 
0x8f706820, 0x32022000, 0x10400004, 0x32020001, 0x0e0001f0, 0x24040001, 
0x32020001, 0x10400003, 0x00000000, 0x0e0000a3, 0x00000000, 0x3c020800, 
0x90421b98, 0x14520003, 0x00000000, 0x0e0004c0, 0x00000000, 0x0a00003c, 
0xaf715028, 0x8fbf001c, 0x8fb20018, 0x8fb10014, 0x8fb00010, 0x03e00008, 
0x27bd0020, 0x27bdffe0, 0x3c040800, 0x24841ac0, 0x00002821, 0x00003021, 
0x00003821, 0xafbf0018, 0xafa00010, 0x0e00067c, 0xafa00014, 0x3c040800, 
0x248423d8, 0xa4800000, 0x3c010800, 0xa0201b98, 0x3c010800, 0xac201b9c, 
0x3c010800, 0xac201ba0, 0x3c010800, 0xac201ba4, 0x3c010800, 0xac201bac, 
0x3c010800, 0xac201bb8, 0x3c010800, 0xac201bbc, 0x8f624434, 0x3c010800, 
0xac221b88, 0x8f624438, 0x3c010800, 0xac221b8c, 0x8f624410, 0xac80f7a8, 
0x3c010800, 0xac201b84, 0x3c010800, 0xac2023e0, 0x3c010800, 0xac2023c8, 

we call these Hexadecimle numbers as blogs and it's hard to impossible 
to know its purpose and effect on our system.  








































































![milestones](https://cloud.githubusercontent.com/assets/17382786/14495088/46ff610e-018e-11e6-960a-b9725c7f6127.png)
