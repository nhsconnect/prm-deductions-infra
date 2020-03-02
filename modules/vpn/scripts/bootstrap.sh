#!/bin/bash -e

set -e

# Make sure apt is available for 8 seconds before starting any installs
# Ubuntu can run upgrade right after boot

i="0"
while [ $i -lt 8 ]; do
  if [ $(fuser /var/lib/dpkg/lock) ]; then
    i="0"
  fi
  sleep 1
  i=$[$i+1]
done

sudo apt-get update
sudo apt-get install -y python2.7 python-simplejson iproute2
