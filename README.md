Debian Paket Sunucusu
=========================

apt-repo-server is a debian repository server. It monitors file changing event(inotify), then reproduce index file(Packages.gz) automatically.


### Kurulum 
```
docker-compose up -d
# WSL içinden veya git bash / Conemu gibi komut satırı programlarının üstünden bash ile
# çalıştırın aşağıdaki kodu (neticede linux içindeki kabuk betiği)
cd package-generator
./gen-package-inside-docker.sh -p cem -v 1.0 -b "cenk(>=1.0.1) canan(>=2.0)"
```


### [exec](https://www.youtube.com/watch?v=MSbpStxXv84)
---------------------
`exec` komutunun buradaki kullanımını göreceğimiz startup.sh dosyasında şöyle geçiyor:

```bash
exec /usr/bin/supervisord -n
```
ubuntu:latest yansısının çalıştırdığı `bash` uygulamasını `exec` ile `/usr/bin/supervisord` uygulamasıyla değiştiriyoruz. Supervisor uygulamasının ayarlarında ise hem nginx başlatılıyor hem de scan.py python uygulaması yönetiliyor:

```ini
[program:nginx]
priority=10
directory=/
command=/usr/sbin/nginx -g "daemon off;"
user=root
autostart=true
autorestart=true
stopsignal=QUIT
redirect_stderr=true

[program:python]
priority=15
directory=/data
command=python /scan.py
user=root
autostart=true
autorestart=true
stopsignal=QUIT
redirect_stderr=true
```


Linux'ta `exec` komutu, bash'ın üzerinden bir komut çalıştırmak için kullanılır. Bu komut yeni bir işlem oluşturmaz, sadece bash'i çalıştıracak komutla değiştirir. `exec` komutu başarılı olursa, çağırma işlemine geri dönmez. `exec` komutu yeni bir işlem oluşturmaz. Terminalden `exec` komutunu çalıştırdığımızda, devam eden terminal işlemi, `exec` komutunun argümanı olarak sağlanan komut ile değiştirilir.

```
exec [-cl] [-a name] [command [arguments]] [redirection ...]

Options:
  c      : Komutu boş ortamda (environment) çalıştırır.
  a name : Komutun sıfırıncı argümanı olarak bir isim vermek için kullanılır
  l      : Komutun sıfırıncı argümanı olarak tire iletmek için kullanılır.
```

### [Supervisord](http://supervisord.org/running.html)
----------------------
Supervisord veya Supervisor arka plan programı (daemon), açık kaynaklı bir süreç yönetim sistemidir. Özetle: bir süreç herhangi bir nedenle çökerse, Supervisor onu yeniden başlatır. Supervisor, kullanıcılarının UNIX benzeri işletim sistemlerinde bir dizi işlemi izlemesini ve kontrol etmesini sağlayan bir istemci/sunucu sistemidir. 

Launchd, daemontools ve runit gibidir ve bu programların bazılarından farklı olarak, “işlem kimliği 1” (pid 1 yani ilk çalışacak program) olarak init'in yerini alacak şekilde çalıştırılması amaçlanmamıştır. Bunun yerine, bir proje veya müşteriyle ilgili süreçleri kontrol etmek için kullanılması ve diğer herhangi bir program gibi önyükleme sırasında başlaması amaçlanmıştır. 

```bash
sudo apt install supervisor
```

`/etc/init.d/supervisord` Dosyası ayarları içerir

``` Dockerfile 
ADD supervisord.conf /etc/supervisor/
```

Hizmet yürütülebilir dosyasının root tarafından sahiplenildiğinden ve yürütülebilir olduğundan emin olun:
```bash
sudo chown root:root /etc/init.d/supervisord
sudo chmod 775 /etc/init.d/supervisord
```

Başlatmak için:
1)
```bash
sudo /etc/init.d/supervisord start
```
2) komut satırında -n bayrağını ileterek ön planda başlatabilirsiniz.


Usage
=======================

Run server

```bash
docker run -it -v ${PWD}/data:/data -p 10000:80 dorowu/apt-repo-server
```

Export a debian package
```bash
cp qnap-fix-input_0.1_all.deb  data/dists/trusty/main/binary-amd64/
```

Ubuntu 20.04 (kod adı focal) ile hazırladım ve dizin yapısı şöyle oldu:
![image](https://user-images.githubusercontent.com/261946/127843724-0aeb7ec5-6873-4085-9c49-7a5027df34c3.png)


Aşağıdaki dizin yapısı 14.04 (trusty) için olup buna dönebilmek için ilk çatalladığım repoya erişmeniz gerekiyor!
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

Update /etc/apt/sources.list
----
Eğer host makinanız üstünden konteynere bağlanacaksanız 
yani konteyner sizin debian paket sunucunu ve host makinanız sizin paketleri çektiğiniz makinanız ise

```bash
echo deb http://127.0.0.1:10000 trusty main | sudo tee -a /etc/apt/sources.list
```

Eğer docker-compose.yml içinde hem debian repo sunucunuz hem de debian paketlerinizi çekeceğiniz bir istemciniz varsa
bu durumda docker-compose.yml içinde her iki konteyner için atanmış ağda bu konteynerler birbirlerini 172.x.x.x IP adresleri üstünden bulacaklardır.
Bu durumda istemciye paket sunucusu olarak şunu vermelisiniz:

```bash
echo deb [trusted=yes] http://172.16.16.2 focal main > /etc/apt/sources.list
```

Repo adresini girdikten sonra size `apt update` ile paket bilgilerini çekmek kalacak:

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

Paket oluşturmak için:
- Hiç bağımlılığı yoksa:
```bash 
# ./paket_uret.sh -p b -v 1.0
```

- Bağımlılığı varsa:
```bash 
# ./paket_uret.sh -p b -v 1.0 -b "a-lib(=1.0), b, c-lib(<<2.0)"
```

![image](https://user-images.githubusercontent.com/261946/127844210-0f758f74-fbe7-4e5a-8364-ff291655179e.png)



License
==================

apt-repo is under the Apache 2.0 license. See the LICENSE file for details.
