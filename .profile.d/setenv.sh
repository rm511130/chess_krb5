echo Kerberos functionality for Garden container being activated. Example created by rmeira@pivotal.io  02/25/2016
echo $KRB5_CONFIG
echo $KRB5_8451
awk '{ print substr($0,2,length($0)-1); }' /home/vcap/app/.profile.d/hash_vcap.keytab | xxd -r > /home/vcap/app/.profile.d/vcap.keytab
chmod 600 /home/vcap/app/.profile.d/vcap.keytab
curl -k -O $KRB5_8451
kinit vcap@EXAMPLE.COM -k -t /home/vcap/app/.profile.d/vcap.keytab
klist
