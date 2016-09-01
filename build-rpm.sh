#!/bin/bash

cleanup()
{
        echo; echo "Cleaning up..."
        rm -rf strongswan-* 2>/dev/null
        exit 1;
}
trap "cleanup" INT EXIT

VER=${VER:=5.4.0}
ITER=${ITER:=1}


if ! curl --output /dev/null --silent --head --fail https://download.strongswan.org/strongswan-${VER}.tar.gz
then
        echo "StrongSwan version $VER doesn't exist"
        exit 1
fi

echo "Downloading StrongSwan $VER source ..."

cd /root
curl -s https://download.strongswan.org/strongswan-${VER}.tar.gz | tar zxf -
echo "Source download complete.. "
cd /root/strongswan-${VER}
./configure --prefix=/usr --sysconfdir=/etc --enable-sql --enable-attr-sql --enable-dhcp --enable-mysql
make
mkdir /tmp/strongswan
make DESTDIR=/tmp/strongswan install

# Copy init script
mkdir -p /tmp/strongswan/etc/init.d
cp /root/strongswan /tmp/strongswan/etc/init.d/
chmod +x /tmp/strongswan/etc/init.d/strongswan

source /etc/profile.d/rvm.sh
fpm -s dir -t rpm -C /tmp/strongswan --name strongswan-mysql --version ${VER}  --iteration ${ITER} --after-install /root/postinstall --before-remove /root/preuninstall --after-remove /root/postuninstall --url "http://www.strongswan.org/" --description "Custom built strongSwan ${VER} with MySQL support"

if [[ -f strongswan-mysql-${VER}-${ITER}.x86_64.rpm ]]
then
        echo "RPM built!!"
        ls -lh /root/strongswan-${VER}/*.rpm
        echo " ======   md5sum   ======="; echo;
        md5sum /root/strongswan-${VER}/*.rpm
        cp /root/strongswan-${VER}/*.rpm /mnt/
        exit 0
else
        echo "Failed to build RPM"
        exit 1
fi
