FROM chenthilvel/fpm
MAINTAINER ChenthilVel
RUN yum -y update && yum -y install gmp-devel mysql-devel
COPY strongswan-init-script /root/strongswan
COPY build-rpm.sh /root/
COPY postinstall postuninstall preuninstall /root/
WORKDIR /root

CMD ["/root/build-rpm.sh" ]