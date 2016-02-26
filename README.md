# chess
Tiny client-side javascript chess game based on the program that won an International Obfuscated C Code Contest

These files are ready to be cf push'ed into a Cloud Foundry environment.
Inside the manifest.yml file I use two CF Environment Variables.
    KRB5_CONFIG: /home/vcap/app/krb5.conf
    KRB5_8451:   https://krb5.apps.192.168.0.98.xip.io/krb5.conf
KRB5_CONFIG points to the location where the container will place a krb5.conf configuration file.
KRB5_8451 points to the location from where the krb5.conf file will be copied

https://krb5.apps.192.168.0.98.xip.io/krb5.conf  is actually part of another github project used to create a static web page that can be used to simulate the download of a krb5.conf file from a secure, known location. See: https://github.com/rm511130/krb5

