set -xe
_version="$1"
_tag="v$1"

_dir=$(pwd)

rm -rf target
mkdir target
cd target
git clone git@github.com:jstachio/jstachio.git
cd jstachio
git checkout ${_tag}
bin/vh set pom
#bin/vh validate

./mvnw -B -ntp clean install -DskipTests=true
./mvnw -B -ntp -f doc clean package -Pjavadoc -DskipTests=true

rm -rf ${_dir}/${_version}

mkdir ${_dir}/${_version}

mv doc/target/site/apidocs ${_dir}/${_version}/

cd ${_dir}

