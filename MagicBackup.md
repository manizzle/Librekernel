#Target: User lose his Librerouter
#Target: User recover all from anew Librerouter from the grid with just a password (40characters with complexity)
#Target: You can recover again all your data, even if your Librerouter breaks down completely.

##What means technically? : 
That we need to backup system files and personal data files in an encrypted part of tahoe space private.

###Asumptions: Tahohe has a public space where no keys are required to acces but just a user.

###Posibilites:  
 - Tahohe runs and the user is fresh  
 - Tahoe runs and is a fesh user trying to recover a previous user keys. To restore the system.

##app-installation-script installs all necesary software
##app-configuration-script configure and runs all necesary software

##app-configuration-script: Functions:
 - a) Check i2p and tor from the system are prepare for tahoe to use conection.
 - b) Intinilize conectors
 - c) Ask if this a recovery system or a fresh one 
 - d) ask for password if recovery
 - e) initialize tahoes in TOR and I2p
 - f) If recovery then locate keys files and extractr files from the public space of tahoe
 - g) Check if password decompres decrpy the keys file
 - h) If so then use those keys to acces private space of the user
 - i) reinitialize tahohe with previous keys
 - j) Extract all data from private space and restore configuration files of system and owncloud home

#Manuel versus script versus GUI wizard
1 User generates tahohe keys
2 user encrypts all keys in a zip file with long password
3 user saves this password in 2 sheet of papers
4 user stores part of the password securely
5 user send zip file to public space in tahoe
6 user uses private encrypt space of tahoe for backupbing part of the Librerouter configuration files,keys , certificates, generated sshs,generated dbpass, dbs , identities and data from him itself example woncloud home directory ,
7 user lost his librerouter device
8 user buy a newone
9 new device connect public space of tahoe (no key are required)
10 user take is zip file
11 user decryp zip
12 user recovery old tahoe keys
13 user recover private space and files
14 user recover all like magic
