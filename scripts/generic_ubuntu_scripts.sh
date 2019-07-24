#!/bin/bash

##to be taken care of by packaging script
#ssh user@rhs-vm-17.storage-dev.lab.eng.bos.redhat.com

#Series (e.g. 4.1)
#Version (e.g. 4.1.0)
#Release (e.g. 1)
#Rname(e.g. xenial/bionic/cosmic/disco/eoan)

##variables
series = $1
version = $2
release = $3
rname = $4

cd src/github/glusterfs-debian/
git checkout -b ${rname}-${series}-local origin/${rname}-glusterfs-${series}

sed -i "1s/^/glusterfs (${version}-ubuntu1~${rname}1) ${rname}; urgency=medium\n\n * GlusterFS ${version} GA \n\n – GlusterFS GlusterFS deb packages <deb.packages@gluster.org> `date +"%a, %d %b %Y %T %z"` \n\n/" debian/changelog

git commit -a -m "Glusterfs ${version} ${rname} G.A"
git push origin ${rname}-${series}-local:${rname}-glusterfs-${series}

sudo pbuilder create --distribution ${rname} --mirror http://ubuntu.osuosl.org/ubuntu/ --debootstrapopts "--keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg"

mkdir build

cd ~/build

TGZS=(`ls ~/glusterfs-${version}-?-*/build/glusterfs-${version}.tar.gz`)

#echo ${TGZS[0]}

if [ -z ${TGZS[0]} ]; then
        echo "wget https://download.gluster.org/pub/gluster/glusterfs/${series}/${version}/glusterfs-${version}.tar.gz"
        wget https://download.gluster.org/pub/gluster/glusterfs/${series}/${version}/glusterfs-${version}.tar.gz
else
        echo "found ${TGZS[0]}, using it..."
        cp ${TGZS[0]} .
fi

ln -s glusterfs-${VERSION}.tar.gz glusterfs_${VERSION}.orig.tar.gz

tar xpf glusterfs-${VERSION}.tar.gz

cd glusterfs-${VERSION}

cp -a /home/glusterpackager/src/github/glusterfs-debian/debian .

debuild -S -sa -k4F5B5CA5

cd ..

##commented for testing purpose
#dput ppa:gluster/glusterfs-${series} glusterfs_${version}-ubuntu1~${rname}${release}_source.changes

cd ..

mkdir glusterfs-${version}-${release}-${rname}

mv build glusterfs-${version}-${release}-${rname}/

echo "Done. Reload the Launchpad page to see the package building"

