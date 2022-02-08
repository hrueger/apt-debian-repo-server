#!/usr/bin/bash

# Ubuntu distribution goes as ubuntu 20.04 if focal, 18.04 if bionic, 16.04 if xenial 
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
    # In every deb file added into the directory, Packages.gz file will be produced by dpkg-scanpackages. 
    # This will trigger inotifywait again and this cycle will be endless
    # To prevent this, "Packages.gz" file will be excluded.
    #
    # Don't forget to not to use PATH named variable!!!! That's why I used FILE_PATH
    #
    # inotifywait triggers the MODIFY event when the file is modified (i.e. written) and every piece of the file is written (in 64k chunks). 
    # The larger the file, the more "file modified" (MODIFY) events are triggered. 
    # At the end of each file creation and modification, it announces the end of the write job with the "close_write" event. 
    # So it would be more efficient to attach to the "close_write" event instead of CREATE and MODIFY. 
    # https://unix.stackexchange.com/questions/462459/inotifywait-tool-shows-multiple-logs-for-same-time-while-replacing-binary
    #
    # With grep we only loop changes in .deb files. (Easier to use than the --exclude switch) 
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

        # It will scan the /data/..../binary-amd64 directory, but it's what each package defines in Package.gz 
        # We want it to write dists/focal/main/binary-amd64 in the FileName field 
        # Because nginx's root directory is /data directory, when downloading the package over http, the default virtual site information is entered. 
        # It will download http://x.x.x.x/dists/focal/main/binary-amd64/<packet.deb> 
        dpkg-scanpackages -m $amd64 | gzip -9c > $amd64/Packages.gz
    done
    echo "Done..."
}

monitor

#& monitor "$amd64" 
#& monitor "$i386" 
