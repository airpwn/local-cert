# Local Setting For My Ubuntu

#### Certificate Installed ####
######Debian/Ubuntu######
```shell 
wget --no-check-certificate https://raw.githubusercontent.com/airpwn/local-cert/master/certs/cert1.crt && wget --no-check-certificate https://raw.githubusercontent.com/airpwn/local-cert/master/certs/cert2.crt  && sudo cp cert*.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates
```
######Centos######
```shell 
wget --no-check-certificate https://raw.githubusercontent.com/airpwn/local-cert/master/certs/cert1.crt;wget --no-check-certificate https://raw.githubusercontent.com/airpwn/local-cert/master/certs/cert2.crt;cp *.crt /etc/pki/ca-trust/source/anchors/;update-ca-trust enable;update-ca-trust extract
```
