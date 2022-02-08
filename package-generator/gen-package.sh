#! /bin/bash

# Usage example: sudo ./canan.sh -p cem -v 1.0 -b "a(=1.0), b(=2)"

# $ sudo ./packet_uret.sh -p a -v 1.0.0.600 -b "a-lib(=1.0.0.322)"
# package name: a
# package version no: 1.0.0.600
# dependent packages: a-lib(=1.0.0.322)
# Package directory does not exist, will be created...
# The a/DEBIAN directory has been created.
# dpkg-deb: building package 'a' in './dists/trusty/main/binary-amd64/a_1.0.0.600.deb'. 

usage="$(basename "$0") package_name version_number dependent_package_name 

Arguments:
     -h shows this help text
     -p package name
     -v is the version number of the package.
     -b contains the package information on which the package is dependent. 

Example:
    $(basename "$0") -p paket_a -v 1.0 -b \"paket_b(>=1.0.1) paket_c(=2.0) paket_d\"
"

while getopts h:p:v:b: flag; do
  case "$flag" in
    h) echo "$usage"
       exit
       ;;
    p) echo "package name: $OPTARG" >&2
       packet_name=${OPTARG}
       ;;
    v) echo "packet version: $OPTARG" >&2
       packet_version=${OPTARG}
       ;;
    b) echo "dependent packages: $OPTARG" >&2
       dependent_packages =${OPTARG}
       ;;
    *) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done

package_build_directory="packets"

if [ ! -d $package_build_directory/${packet_name}/DEBIAN ]
then
  echo "Paket dizini mevcut degil olusturulacak..."
  mkdir -m 775 -p "${package_build_directory}/${packet_name}/DEBIAN"  
  # chmod -R 775 ./$package_build_directory/$packet_name/DEBIAN

  if [ $? -eq 0 ]; then
    echo "${packet_name}/DEBIAN directory created ."
  else
    echo "Could not create directory!"
    exit 1
  fi
fi

# DEBIAN definition file will be created 
cat << EOF > ./$package_build_directory/$packet_name/DEBIAN/control
Package: $packet_name
Version: $packet_version
Architecture: amd64
Maintainer: a
Depends: $dependent_packages 
Conflicts:
Section: web
Priority: standard
Description: retrieves files from the web
EOF


if [ $? -ne 0 ]; then
  echo "./$package_build_directory/$packet_name/DEBIAN/control file could not be created!"
  exit 1
fi

repo_package_directory ="/data/dists/focal/main/binary-amd64"

if [ ! -d "$repo_package_directory " ]
then
    echo "The directory ($repo_package_directory) where the package will be installed and the docker repo will scan does not exist, it will be extracted !"
    exit 1
fi

dpkg-deb  -b  ./$package_build_directory/$packet_name  $repo_package_directory /${packet_name}_${packet_version}.deb
