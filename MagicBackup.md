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

**In script can be two choises:** 
1. new device from scratch - steps 1-6
2. Restore lost device  - steps 9-14

**Steps:**

1. User generates tahoe keys 
Keys generated after run 'tahoe create-node' or 'tahoe create-client'
Q: Routers will participate in tahoe grid as storage node or can be only clients?

2. User encrypts all keys in a zip file with long password
This part do script, before zipped this - script ask password from user.

3. User saves this password in 2 sheet of papers 

4. User stores part of the password securely 

5. ~~user~~ Script send zip file to public space in tahoe
Q: All files to one directory? Filename is hostname_DDMMYY.zip?

6. User uses private encrypt space of tahoe for backuping part of the Librerouter configuration files,keys , certificates, generated sshs,generated dbpass, dbs , identities and data from him itself example owncloud home directory
Use another script ~ backup.sh

7. User lost his librerouter device

8. User buy a new one 

9. New device connect public space of tahoe (no key are required)
but tahoe generate new keys after first run

10. User take is zip file 
  Find by name?
 
11. User decrypt zip 
    Script ask password

12. User recovery old tahoe keys (replace keys) 
    and restart tahoe

13. User recover private space and files 
    Use another script ~ restore.sh

14. User recover all like magic

Q: Have you plan to take hostnames for routers? It would be very good if we have unique name for tahoe node and, perhaps, for hostname. Node nickname can be zipped witch keys
