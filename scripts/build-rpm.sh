#!/bin/bash
NAME="python-docker-py"
platforms=(epel-6-i386 fedora-17-i386 fedora-18-i386 fedora-19-i386)

if [ -z $1 ]
then
  VERSION=`git describe --long --tags | awk -F"-" '{print $1}'`
else
  VERSION=$1
fi

if [ -z $2 ]
then
  RELEASE=`git describe --long --tags | awk -F"-" '{print $2}'`
else
  RELEASE=$2
fi

COMMIT=`git describe --long --tags | awk -F"-" '{print $3}'`

cd `dirname $0`
cd ..


sed "s/#VERSION#/${VERSION}/g" ${NAME}.spec.template > ${NAME}.spec
sed -i "s/#RELEASE#/${RELEASE}/g" ${NAME}.spec
sed -i "s/#COMMIT#/${COMMIT}/g" ${NAME}.spec

tar -cvzf $HOME/rpmbuild/SOURCES/${NAME}-${VERSION}-${RELEASE}.tar.gz * \
--exclude .git \
--exclude build \
--exclude dist \
--exclude deb_dist \
--exclude tests \
--exclude devel \
--exclude docker-py.egg-info \
--exclude custom_plugins


rpmbuild -ba ${NAME}.spec

if [ -f "/usr/bin/mock" ]
then
for platform in "${platforms[@]}"
do
    /usr/bin/mock -r ${platform} --rebuild $HOME/rpmbuild/SRPMS/${NAME}-${VERSION}-${RELEASE}*.src.rpm
done
fi
