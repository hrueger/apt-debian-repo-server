#Docker debian repository makinesindeki /debrepo dizini nfs share olarak kullanılmaktadır.
#Bu script ile NFS server tarafında /debrepo dizini altındaki paket guncellemeleri otomatik olarak algılanıp, scan edilir.

#!/usr/bin/bash

nginx_root=/data
amd64=dists/focal/main/binary-amd64
#i386=/data/dists/focal/main/binary-i386

monitor() {
   while inotifywait -e attrib,modify,create,delete $nginx_root/$amd64
   do
        echo ">> packages updated folder:" $nginx_root/$amd64
        #rsync -avz --exclude 'amd64/' $1/ $1/amd64/

        cd $nginx_root
        #dpkg-scanpackages -m dists/focal/main/binary-amd64 | gzip -9c > Packages.gz

        # /data/..../binary-amd64 dizinini tarayacak ancak her paketin Package.gz içinde tanımladığı
        # FileName alanına dists/focal/main/binary-amd64 yazmasını istiyoruz
        # Çünkü nginx'in root dizini /data dizini olduğu için http üstünden paketi indirirken default virtual site bilgilerine
        # http://x.x.x.x/dists/focal/main/binary-amd64/<paket.deb>  diyerek indirmesini sağlayacak
        dpkg-scanpackages -m $amd64 | gzip -9c > $amd64/Packages.gz
    done
}

monitor

#& monitor "$amd64" 
#& monitor "$i386" 
