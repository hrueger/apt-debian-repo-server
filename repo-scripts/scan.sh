#Docker debian repository makinesindeki /debrepo dizini nfs share olarak kullanılmaktadır.
#Bu script ile NFS server tarafında /debrepo dizini altındaki paket guncellemeleri otomatik olarak algılanıp, scan edilir. 
#!/usr/bin/bash

# Ubuntu dağıtımı eğer focal ise ubuntu 20.04, bionic ise 18.04, xenial ise 16.04 diye gidiyor
distName=${DISTS-:focal}
nginx_root=/data
amd64="dists/$distName/main/binary-amd64"
#i386=/data/dists/focal/main/binary-i386

monitor() {

    [ ! -d $nginx_root/$amd64 ] || mkdir -p $nginx_root/$amd64

    printf "\e[1;34m%-6s\e[m" "...::: >> Debian packages updated folder: $nginx_root/$amd64 :::..."
    printf "\n$nginx_root/$amd64"

    # inotifywait $nginx_root/$amd64 --monitor --event access --event attrib --event modify --event create --event delete | while read  PATH ACTION FILE
    
    ##################################################################################################
    # In every deb file added into the directory, Pacakges.gz file will be produced by dpkg-scanpackages. 
    # This will trigger inotifywait again and this cycle will be endless
    # To prevent this, "Packages.gz" file will be excluded.
    #
    # Don't forget to not to use PATH named variable!!!! That's why I used FILE_PATH
    #
    # inotifywait dosya değiştirildiğinde (yani yazıldığında) dosyanın her parçası (64k büyüklüğünde parçalar halinde) yazıldığında MODIFY olayını tetikler.
    # Dosya ne kadar büyükse o kadar çok "dosya değiştirildi" (MODIFY) olayı tetiklenir.
    # Her dosya  oluşturma ve değiştirme sonunda yazma işinin son bulduğunu "close_write" olayıyla duyurur.
    # Bu yüzden CREATE ve MODIFY yerine "close_write" olayına eklemlenmek daha verimli olacaktır.
    # https://unix.stackexchange.com/questions/462459/inotifywait-tool-shows-multiple-logs-for-same-time-while-replacing-binary
    #
    # grep ile sadece .deb dosyalarındaki değişimleri döngüye atıyoruz. (--exclude anahtarından daha kolay kullanırız deyu)
    ##################################################################################################
    # inotifywait $nginx_root/$amd64 --monitor --event create | while read  FILE_PATH ACTION FILE
    # inotifywait $nginx_root/$amd64 --monitor --event create --format '%w%f' | while read  FILE  # Sadece dosyanın tam yolunu alırız.
    inotifywait $nginx_root/$amd64 --monitor --exclude "[^deb]$" --event close_write --event delete \
    | grep '.deb$' --line-buffered \
    | while read  FILE_PATH ACTION FILE
    do
        #rsync -avz --exclude 'amd64/' $1/ $1/amd64/
        printf "\e[1;34m%-6s\e[m \n" "...::: >> New package came into scene: $FILE :::..."
        printf "\e[1;34m%-6s\e[m \n" "...::: >> FILE: $FILE "
        printf "\e[1;34m%-6s\e[m \n" "...::: >> FILE_PATH: $FILE_PATH "
        printf "\e[1;34m%-6s\e[m \n" "...::: >> ACTION: $ACTION "
        cd $nginx_root

        # /data/..../binary-amd64 dizinini tarayacak ancak her paketin Package.gz içinde tanımladığı
        # FileName alanına dists/focal/main/binary-amd64 yazmasını istiyoruz
        # Çünkü nginx'in root dizini /data dizini olduğu için http üstünden paketi indirirken default virtual site bilgilerine
        # http://x.x.x.x/dists/focal/main/binary-amd64/<paket.deb>  diyerek indirmesini sağlayacak
        dpkg-scanpackages -m $amd64 | gzip -9c > $amd64/Packages.gz
    done
        echo "cenkkkkk"
}

monitor

#& monitor "$amd64" 
#& monitor "$i386" 
