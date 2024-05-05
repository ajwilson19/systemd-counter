#!/bin/bash
#

if [ ! -d "counter-v2.0.0" ]; then
    mkdir counter-v2.0.0
fi

mkdir -p counter-v2.0.0/DEBIAN
mkdir -p counter-v2.0.0/usr/bin
mkdir -p counter-v2.0.0/etc/systemd/system

echo 'Source: counter
Section: misc
Priority: optional
Maintainer: AJ Wilson <awilson22@zagmail.gonzaga.edu>
Build-Depends: bash
Standards-Version: 3.9.4
Homepage: http://github.com/ajwilson19
Package: counter
Version: 2.0.0
Architecture: amd64
Depends: lintian,
	 make
Description: Counter service written in Rust' > counter-v2.0.0/DEBIAN/control

echo '[Unit]
Description=Rust Counter Daemon

[Service]
User=counter
ExecStart=/usr/bin/counter

[Install]
WantedBy=multi-user.target' > counter-v2.0.0/etc/systemd/system/counter.service

echo '#!/bin/bash
echo postinst
sudo adduser --system  counter
sudo chmod 0755 /usr/bin/counter
sudo chown counter:counter /usr/bin/counter
sudo systemctl daemon-reload
sudo systemctl enable counter.service
sudo systemctl start counter.service' > counter-v2.0.0/DEBIAN/postinst
chmod +x counter-v2.0.0/DEBIAN/postinst

echo '#!/bin/bash
echo prerm
sudo systemctl stop counter.service
sudo systemctl disable counter.service
sudo rm -f /etc/systemd/system/counter.service
sudo rm -f /usr/bin/counter
sudo rm -f /tmp/currentCount.out' > counter-v2.0.0/DEBIAN/prerm
chmod +x counter-v2.0.0/DEBIAN/prerm

echo '#!/bin/bash
echo postrm
sudo systemctl daemon-reload
sudo userdel counter' > counter-v2.0.0/DEBIAN/postrm
chmod +x counter-v2.0.0/DEBIAN/postrm
