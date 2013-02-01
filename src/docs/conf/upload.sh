#!/bin/bash
set -e
set -x

DIR=$(cd `dirname $0` && cd ../../../ && pwd)

# Uploads the manual to a public server.


# Which version the documentation is now.
VERSION=$(cat $DIR/target/conf/version)
if [ -z "$VERSION" ]; then
	exit 1;
fi

# Name of the symlink created on the docs server, pointing to this version.
if [[ $VERSION == *SNAPSHOT* ]]
then
	SYMLINKVERSION=snapshot
else
	if [[ $VERSION == *M* ]]
	then
		SYMLINKVERSION=milestone
	else
		SYMLINKVERSION=stable
	fi
fi
DOCS_SERVER='neo@static.neo4j.org'
ROOTPATHDOCS='/var/www/docs.neo4j.org/python-embedded'

echo "VERSION = $VERSION"
echo "SYMLINKVERSION = $SYMLINKVERSION"

# Create initial directories
ssh $DOCS_SERVER mkdir -p $ROOTPATHDOCS/$VERSION

# Copy artifacts
rsync -r --delete $DIR/target/html5/ $DOCS_SERVER:$ROOTPATHDOCS/$VERSION/
# Symlink this version to a generic url
ssh $DOCS_SERVER "cd $ROOTPATHDOCS/ && (rm $SYMLINKVERSION || true); ln -s $VERSION $SYMLINKVERSION"

echo Apparently, successfully published to $DOCS_SERVER.


