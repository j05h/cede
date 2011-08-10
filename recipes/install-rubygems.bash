### Determine the type of distribution.

if [ -f "/etc/redhat-release" ]; then
  REDHAT=true
elif [ -f "/etc/issue" ]; then
  DEBIAN=true
else
  echo "INFO: Exiting... Distribution currently not supported!"

  exit 0
fi

if [ "${REDHAT}" = "true" ]; then
  ### Setup EPEL and install the prerequisites.

  rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm

  yum update -qy
  yum install -qy gcc gcc-c++ automake autoconf make curl
  yum install -qy openssl openssl-devel readline readline-devel zlib zlib-devel
elif [ "${DEBIAN}" = "true" ]; then
  apt-get install -qy build-essential libssl-dev libreadline-dev curl ssl-cert curl
  apt-get install -qy libxslt-dev libxml2-dev
fi

### Download Ruby;

pushd /tmp

RUBY=ruby-1.9.2-p180
curl -O ftp://ftp.ruby-lang.org/pub/ruby/1.9/${RUBY}.tar.gz
tar -zxvf ${RUBY}.tar.gz

### Install Ruby;

cd ${RUBY}

./configure --prefix=/usr/local
make
make install-nodoc

### Download Rubygems;

popd && pushd .

RUBYGEMS=rubygems-1.6.2
curl -O http://production.cf.rubygems.org/rubygems/${RUBYGEMS}.tgz
tar -xzvf ${RUBYGEMS}.tgz

### Install Rubygems;

cd ${RUBYGEMS}
ruby setup.rb --no-rdoc --no-ri
