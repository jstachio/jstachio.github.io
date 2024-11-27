set -xe
_version="$1"
_tag="v$1"
_project=kiwi

_dir=$(pwd)

rm -rf target
mkdir target
cd target
git clone git@github.com:jstachio/${_project}.git
cd ${_project} 
git checkout ${_tag}
bin/vh set pom
#bin/vh validate

#./mvnw -B -ntp clean install -DskipTests=true
./mvnw -B -ntp clean package -Pdoc -Ddeploy=release -Duser.timezone=UTC -DskipTests=true

rm -rf ${_dir}/${_version}

mkdir ${_dir}/${_version}

mv target/reports/apidocs ${_dir}/${_version}/

cd ${_dir}

rm current

ln -s ${_version} current

