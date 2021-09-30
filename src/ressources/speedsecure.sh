#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then
    echo "Please run as root" exit 1
fi

if [ -f "resume.txt" ]
then
    rm resume.txt
fi

wantVPN="undefined"
while [ "$wantVPN" != "y" ] && [ "$wantVPN" != "n" ]
do
    echo "Voulez-vous installer un serveur VPN sur votre machine ? [y/n]"
    read wantVPN
    echo $wantVPN
done

IP_Publique=$(wget -qO- icanhazip.com)
Port_SSH=$(awk -v min=10000 -v max=20000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')


touch resume.txt
apt-get update
apt-get install -y software-properties-common cron-apt pwgen proftpd openssh-server fail2ban curl software-properties-common nftables
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install -y certbot

if [ -f "/etc/ssh/sshd_config" ]
then
    FILE_SSH="/etc/ssh/sshd_config"
else
    FILE_SSH="/etc/ssh/ssh_config"
fi


changeRootPassword()
{
    echo "je change le mdp"
    # Installation pwgen
    password_root=$(pwgen 13 1)
    echo "root:$password_root" | chpassw
    echo "Votre mot de passe root est $password_root"
    echo "Votre mot de passe root est $password_root" >> resume.txt
}

changePortSSH()
{
    echo "check $1"
    #Supprimer l'ancien port
    sed -i '/Port /d' $FILE_SSH
    echo "Port $Port_SSH" >> $FILE_SSH
    #Ajouter nouveau port
    echo "Port ssh : $Port_SSH" >> resume.txt
}

changePortFTP()
{
    Port_FTP=$(awk -v min=20000 -v max=30000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
    sed -i '/Port\t\t\t\t21/d' /etc/proftpd/proftpd.conf
    echo "Port $Port_FTP" >> /etc/proftpd/proftpd.conf
    echo "Port ftp : $Port_FTP" >> resume.txt
}

changePortMysql()
{
    Port_DB=$(awk -v min=30000 -v max=40000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
    MySQL=$(dpkg -l | grep -e 'mysql-server ' | wc -l)
    MariaDB=$(dpkg -l | grep -e 'mariadb-server ' | wc -l)

    if [ $MySQL = "1" ]
    then
        sed -i -e "s/port                   = 3306/port = $Port_DB/g" /etc/mysql/my.cnf
        service mysql restart
    elif [ $MariaDB = "1" ]
    then
        sed -i -e "s/#port                   = 3306/port = $Port_DB/g" /etc/mysql/mariadb.conf.d/50-server.cnf
        service mysql restart
    fi
    echo "Port mysql : $Port_DB" >> resume.txt
}

disableRootSSH()
{
    if grep "PermitRootLogin prohibit-password" $FILE_SSH
    then
        sed -i "/PermitRootLogin prohibit-password/d" $FILE_SSH
        echo "PermitRootLogin no" >> $FILE_SSH
        service ssh restart
    elif grep "#PermitRootLogin prohibit-password" $FILE_SSH
    then
        sed -i "#PermitRootLogin yes/d" $FILE_SSH
        echo "PermitRootLogin no" >> $FILE_SSH
        service ssh restart
    elif grep "#PermitRootLogin yes" $FILE_SSH
    then
        sed -i "/PermitRootLogin yes/d" $FILE_SSH
        echo "PermitRootLogin no" >> $FILE_SSH
        service ssh restart
    elif grep "PermitRootLogin yes" $FILE_SSH
    then
        sed -i "/PermitRootLogin yes/d" $FILE_SSH
        echo "PermitRootLogin no" >> $FILE_SSH
        service ssh restart
    fi

    echo "Accès root en ssh désactivé"
}

keySSH()
{
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""
    echo "Votre clé ssh est disponible ici : ~/.ssh/id_ed25519.pub"
    echo "Votre clé ssh est disponible ici : ~/.ssh/id_ed25519.pub" >> resume.txt

    sed -i '/#PubkeyAuthentication yes/d' $FILE_SSH
    echo "PubkeyAuthentication yes" >> $FILE_SSH
    sed -i '/#PasswordAuthentication yes/d' $FILE_SSH
    echo "PasswordAuthentication no" >> $FILE_SSH

    service ssh restart
    service ssh restart
}

configureFail2Ban()
{
    # Bantime => 1H
    sed -i -e "s/bantime = 10m/bantime = 3600/g" /etc/fail2ban/jail.conf

    # MaxRetry => 3
    sed -i -e "s/maxretry = 3/maxretry = 3/g" /etc/fail2ban/jail.conf

    # IgnoreIP
    sed -i '/#ignoreip /d' /etc/fail2ban/jail.conf
    # sed -i '/backend = systemd /d' /etc/fail2ban/jail.conf
    sed -i -e '/ignoreip/aignoreip = '$IP_Publique'' /etc/fail2ban/jail.conf

    checkFail2ban=$(service fail2ban status | grep 'fail2ban is running' | wc -l)
    # Restart service
    service fail2ban restart

    if [ $checkFail2ban = "0" ]
    then
        sed -i -e "s/backend = %(sshd_backend)s/backend = systemd/" /etc/fail2ban/jail.conf
        service fail2ban restart
    fi
}

configureVPN()
{
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh
    AUTO_INSTALL=y ./openvpn-install.sh
}

configureCertBot()
{
    systemctl stop nginx
    ou
    systemctl stop apache
    echo "Nom de votre domaine :"
    read $Nom_Domaine
    certbot certonly --standalone --agree-tos --no-eff-email -d $Nom_Domaine -d www.$Nom_Domaine --rsa-key-size 4096

    Apache=$(dpkg -l | grep -e 'apache2 ' | wc -l)
    Nginx=$(dpkg -l | grep -e 'nginx ' | wc -l)

    if [ $Apache = "1" ]
    then
        service apache2 restart
    elif [ $Nginx = "1" ]
    then
        service nginx restart
    fi
}


configureFireWall()
{
    flush ruleset
    add table filter
    add table nat

    # Par défaut on bloque tout
    add chain filter input { type filter hook input priority 0; policy drop ;}
    add chain filter output { type filter hook output priority 0; policy drop ;}
    add chain filter forward { type filter hook forward priority 0; policy drop ;}
    add chain nat prerout { type nat hook prerouting priority 0; }
    add chain nat postrout { type nat hook postrouting priority 0; }

    #Autorisation des retours
    add rule filter input ct state established accept
    add rule filter output ct state established accept
    add rule filter forward ct state established accept

    #Entrée
    add rule filter input iifname "lo" accept
    add rule filter input ip protocol icmp accept

    #Accepter le ssh  depuis une IP interne
    add rule filter input iifname "ens33" tcp dport $ counter accept

    #Sortie
    add rule filter output oifname "lo" accept
    add rule filter output ip protocol icmp accept
    add rule filter output ip protocol tcp tcp dport { 80,443} accept
    add rule filter output ip protocol udp udp dport 53 accept

    #dnat

    add rule filter forward ip protocol tcp ip daddr 192.168.226.144 tcp dport { 80,443} accept

    #snat
    add rule filter forward ip protocol udp ip saddr 192.168.226.144 udp dport 53 counter accept
    add rule filter forward ip protocol tcp ip saddr 192.168.226.144 tcp dport { 80,443} counter accept

    add rule nat postrout ip saddr 192.168.226.144 snat $IP_Publique
}

changeRootPassword
changePortSSH
changePortFTP
changePortMysql
configureFail2Ban
disableRootSSH
keySSH
configureCertBot

if [ "$wantVPN" = "y" ]
then
    configureVPN
fi
