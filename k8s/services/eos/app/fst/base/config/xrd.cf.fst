###########################################################
xrootd.fslib -2 libXrdEosFst.so
xrootd.async off nosf
xrd.network keepalive
###########################################################
xrootd.seclib libXrdSec.so
sec.protocol unix
sec.protocol sss -c /etc/eos.keytab -s /etc/eos.keytab
sec.protbind * only unix sss
###########################################################
all.export / nolock
all.trace none
all.manager localhost 2131
#ofs.trace open
###########################################################
xrd.port 1095
ofs.persist off
ofs.osslib libEosFstOss.so
ofs.tpc pgm /opt/eos/xrootd/bin/xrdcp
###########################################################
fstofs.broker root://mgm.services-eos.svc.c.k3s.fsn.lama.tel:1097//eos/
fstofs.autoboot true
fstofs.quotainterval 10
fstofs.metalog /var/eos/md/
fstofs.fmddict /var/eos/md/fstfmd.dict
##### QuarkDB #############################################
fstofs.qdbcluster qdb.services-eos.svc.c.k3s.fsn.lama.tel:7777
fstofs.qdbpassword_file /etc/eos.keytab
##### HTTP ################################################
# all.sitename eos
# http.exthandler EosFstHttp libEosFstHttp.so none
# http.exthandler xrdtpc libXrdHttpTPC.so
# http.trace all
# xrd.protocol XrdHttp:8443 libXrdHttp.so
# xrd.timeout idle 86400
# xrd.tlsca certdir /etc/grid-security/certificates/
# xrd.tls /etc/grid-security/daemon/hostcert.pem /etc/grid-security/daemon/hostkey.pem
###########################################################
