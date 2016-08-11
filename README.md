# chess_krb5
Tiny client-side javascript chess game based on the program that won an International Obfuscated C Code Contest ... used in this example to show how to Kereberize an App that is running on Pivotal Cloud Foundry

# Kerberos Notes
The files in this repository are ready to be cf push'ed into a Cloud Foundry environment.
Inside the manifest.yml file I use two CF Environment Variables to exemplify how to set-up a Kerberos aware Cloud Foundry container.
    
    KRB5_CONFIG: /home/vcap/app/krb5.conf
    KRB5_8451:   https://krb5.apps.192.168.0.98.xip.io/krb5.conf

KRB5_CONFIG points to the location where the container will place a krb5.conf configuration file

KRB5_8451 points to the location from where the krb5.conf file will be copied

In this example the URL https://krb5.apps.192.168.0.98.xip.io/krb5.conf  is actually part of another github project used to create a static web page that I used to simulate the download of a krb5.conf file from a secure, known location. See: https://github.com/rm511130/krb5

# .profile.d

Two things happen to any file you place in the .profile.d directory.

(1) The file(s) is (are) copied into the container and placed under /home/vcap/app/.profile.d/ as part of the cf push process. 

(2) The file(s) is (are) executed as part of the container set-up process.

# hash_vcap.keytab

Normally, the keytab file (think of it as a password file) would be embedded in a jar file built by a CI/CD pipeline, but in this example I'm just striving to demonstrate the basic kerberos mechanism at work, so I took the keytab file "vcap.keytab" produced by a Kerberos Server and had it converted into "hash_vcap.keytab" using the following commands:

$ xxd vcap.keytab | awk '{ printf("#%s\n",$0) }' > hash_vcap.keytab

Note that the hash_vcap.keytab file will be copied into the container(s) and executed as part of the cf push process, but it's contents will be seen by Ubuntu as just shell comments, given the "#" symbol at the beginning of each line.

# setenv.sh

The second file I included in the .profile.d directory performs 8 steps:

(1) echo Kerberos functionality for Garden container being activated. Example created by rmeira@pivotal.io  02/25/2016

(2) echo $KRB5_CONFIG ## prints to cf logs the contents of the KRB5_CONFIG i.e. /home/vcap/app/krb5.conf

(3) echo $KRB5_8451 ## prints to cf logs the contents of KRB5_8451 i.e. download location for the krb5.conf file

(4) awk '{ print substr($0,2,length($0)-1); }' /home/vcap/app/.profile.d/hash_vcap.keytab | xxd -r > /home/vcap/app/.profile.d/vcap.keytab   ## i.e. commands to recreate the original vcap.keytab file

(5) chmod 600 /home/vcap/app/.profile.d/vcap.keytab  ## sets the correct permissions on vcap.keytab

(6) curl -k -O $KRB5_8451  ## downloads the krb5.conf from my example's location: https://krb5.apps.192.168.0.98.xip.io/krb5.conf

(7) kinit vcap@EXAMPLE.COM -k -t /home/vcap/app/.profile.d/vcap.keytab  ## requests a Ticket Granting Ticket from the Kerberos server

(8) klist  ## Displays the list of currently cached kerberos tickets ... i.e. demonstrates that the App running in PCF has contacted the Kerberos Server and was authenticated.

# How was the vcap.keytab file originally created?

I installed a KDC on a virtual machine in the example.com domain and initialized a Kerberos DB:

[root@secondary ~]# hostname -f

secondary.example.com

[root@secondary ~]# yum -y install krb5-libs krb5-server krb5-workstation  

[root@secondary ~]# kdb5_util create -s  

I started Kerberos and created some necessary users, and then created the vcap.keytab file which I then used as decribed in the sections above.

[root]# /sbin/service krb5kdc start  

[root]# /sbin/service kadmin start 

[root]# kadmin.local -q "addprinc root/admin" 

[root@secondary krb5kdc]# adduser vcap

[root@secondary krb5kdc]# kadmin.local

kadmin.local:  ank vcap

kadmin.local:  ktadd -k /home/vcap/vcap.keytab vcap

kadmin.local:  quit

[root@secondary krb5kdc]# su vcap

[vcap@secondary krb5kdc]$ cd ~

[vcap@secondary ~]$ ls –las | grep keytab

4 -rw-------   1 root root  334 Feb 24 19:19 vcap.keytab

















