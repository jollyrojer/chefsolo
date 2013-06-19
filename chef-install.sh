#!/bin/bash -x

CHEF_VERSION="10.16.2"
start=`date +%s`

if [ ! `which chef-client 2>/dev/null` ]; then

    if [ $UID -ne 0 ]; then
      SUDO=`which sudo 2>/dev/null`
      if [ ! -x "$SUDO" ]; then
        echo "$0: root access required, but sudo not found." >&2
        exit 127
      fi
      exec $SUDO $0 $@
    fi

    CURL=`which curl 2>/dev/null`
    WGET=`which wget 2>/dev/null`
    if [ -x "$CURL" ]; then
      # Centos 6 do have curl in *minimal package
      bash <($CURL -L http://www.opscode.com/chef/install.sh) -v $CHEF_VERSION
    elif [ -x "$WGET" ]; then
      bash <($WGET -O - http://www.opscode.com/chef/install.sh) -v $CHEF_VERSION
    else
      echo "$0: Cannot find wget or curl - cannot install Chef!" >&2
      exit 127
    fi

    # Do our best to adjust time
    if [ ! `which ntpdate 2>/dev/null` ]; then
      if [ `which apt-get 2>/dev/null` ]; then
        apt-get -y --force-yes install ntpdate
      elif [ `which yum 2>/dev/null` ]; then
        yum -y install ntpdate
      else
        echo "Cannot install ntpdate" >&2
      fi
    fi

    ntpdate pool.ntp.org || true

fi

end=`date +%s`
echo "done in $((end - start)) sec"

exit `which chef-client &>/dev/null; echo $?`
