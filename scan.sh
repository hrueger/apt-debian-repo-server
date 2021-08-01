#Docker debian repository makinesindeki /debrepo dizini nfs share olarak kullanılmaktadır.
#Bu script ile NFS server tarafında /debrepo dizini altındaki paket guncellemeleri otomatik olarak algılanıp, scan edilir.

#!/bin/bash

amd64=/data/dists/focal/main/binary-amd64
i386=/data/dists/focal/main/binary-i386

monitor() {
   while inotifywait -e attrib,modify,create,delete $1
   do
        echo "packages updated folder:" $1/
        #rsync -avz --exclude 'amd64/' $1/ $1/amd64/
        cd $1
        dpkg-scanpackages -m . /dev/null | gzip -9c > Packages.gz
    done
}

monitor "$amd64" 
#& monitor "$i386" 
