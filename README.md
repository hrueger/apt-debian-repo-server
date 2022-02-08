# Debian Packet Server
=========================

apt-repo-server is a debian repository server. It monitors file changing event(inotify), then reproduce index file(Packages.gz) automatically.


## Setup 
```
docker-compose up -d
# With bash from within WSL or above command line programs like git bash / Conemu 
# run the following code (the shell script in linux after all) 
cd package-generator
./gen-package-inside-docker.sh -p cem -v 1.0 -b "cenk(>=1.0.1) canan(>=2.0)"
```

## Usage

### Run server

```bash
docker run -it -v ${PWD}/data:/data -p 10000:80 dorowu/apt-repo-server
```

### Export a debian package
```bash
cp qnap-fix-input_0.1_all.deb  data/dists/trusty/main/binary-amd64/
```

I prepared it with Ubuntu 20.04 (codename focal) and the directory structure was like this:
![image](https://user-images.githubusercontent.com/261946/127843724-0aeb7ec5-6873-4085-9c49-7a5027df34c3.png)

The directory structure below is for 14.04 (trusty) and you need to access the first repo I forked to revert to it! 
```bash
tree data/
data/
└── dists
    ├── precise
    │   └── main
    │       ├── binary-amd64
    │       │   └── Packages.gz
    │       └── binary-i386
    │           └── Packages.gz
    └── trusty
        └── main
            ├── binary-amd64
            │   ├── Packages.gz
            │   └── qnap-fix-input_0.1_all.deb
            └── binary-i386
                └── Packages.gz
```

Packages.gz looks like
```bash
zcat data/dists/trusty/main/binary-amd64/Packages.gz
Package: qnap-fix-input
Version: 0.1
Architecture: all
Maintainer: Doro Wu <dorowu@qnap.com>
Installed-Size: 33
Filename: ./qnap-fix-input_0.1_all.deb
Size: 1410
MD5sum: 8c08f13d61da1b8dc355443044bb2608
SHA1: 6deef134c94da7f03846a6b74c9e4258c514868f
SHA256: 7441f1616810d5893510d31eac2da18d07b8c13225fd2136e6a380aefe33c815
Section: utils
Priority: extra
Description: QNAP fix
 UNKNOWN
```

### Update /etc/apt/sources.list
If you are going to connect to the container on your host machine
that is, if the container is your debian package server and your host machine is your machine from which you pull the packages 

```bash
echo deb http://127.0.0.1:10000 trusty main | sudo tee -a /etc/apt/sources.list
```

If you have both a debian repo server in docker-compose.yml and a client to pull your debian packages from
In this case, in the network assigned for both containers in docker-compose.yml, these containers will find each other over the 172.x.x.x IP addresses.
In this case, you must give the client as the packet server: 

```bash
echo deb [trusted=yes] http://172.16.16.2 focal main > /etc/apt/sources.list
```

After entering the repo address, you will have to pull the package information with `apt update`: 

```
root@688b7d95e1c6:/# echo deb [trusted=yes] http://172.16.16.2 focal main > /etc/apt/sources.list

root@688b7d95e1c6:/# apt update
Ign:1 http://172.16.16.2 focal InRelease
Ign:2 http://172.16.16.2 focal Release
Ign:3 http://172.16.16.2 focal/main all Packages
Get:4 http://172.16.16.2 focal/main amd64 Packages [261 B]
Ign:3 http://172.16.16.2 focal/main all Packages
Ign:3 http://172.16.16.2 focal/main all Packages
Ign:3 http://172.16.16.2 focal/main all Packages
Ign:3 http://172.16.16.2 focal/main all Packages
Ign:3 http://172.16.16.2 focal/main all Packages
Ign:3 http://172.16.16.2 focal/main all Packages
Fetched 261 B in 0s (16.6 kB/s)
Reading package lists... Done
Building dependency tree
Reading state information... Done
All packages are up to date.
root@688b7d95e1c6:/#
root@688b7d95e1c6:/# apt list b
Listing... Done
b/unknown 1.0 amd64
```

![image](https://user-images.githubusercontent.com/261946/127844011-e011adff-2b3c-4bb5-ab35-6ec5eb81fa01.png)

To create a package:
- If it has no dependencies:
```bash
# ./gen_package.sh -p b -v 1.0
```

- If it has an dependency:
```bash
# ./gen_package.sh -p b -v 1.0 -b "a-lib(=1.0), b, c-lib(<<2.0)"
``` 

![image](https://user-images.githubusercontent.com/261946/127844210-0f758f74-fbe7-4e5a-8364-ff291655179e.png)



## License

apt-repo is under the Apache 2.0 license. See the LICENSE file for details.
