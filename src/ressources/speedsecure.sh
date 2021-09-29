#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then
    echo "Please run as root" exit 1
fi

if [ -f "resume.txt" ]
then
    rm resume.txt
fi

if [ -f "/etc/ssh/sshd_config" ]
then
    FILE_SSH="/etc/ssh/sshd_config"
else
    FILE_SSH="/etc/ssh/ssh_config"
fi

touch resume.txt
apt-get update

changeRootPassword()
{
    echo "je change le mdp"
    # Installation pwgen
    apt-get install -y pwgen
    password_root=$(pwgen 13 1)
    echo "root:$password_root" | chpassw
    echo "Votre mot de passe root est $password_root"
    echo "Votre mot de passe root est $password_root" >> resume.txt
}

changePortSSH()
{
    echo "check $1"
    rand=$(awk -v min=10000 -v max=20000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
    #Supprimer l'ancien port
    sed -i '/Port /d' $FILE_SSH
    echo "Port $rand" >> $FILE_SSH
    #Ajouter nouveau port
    echo "Port ssh : $rand" >> resume.txt
}

changePortFTP()
{
    apt-get install -y proftpd
    Port_FTP=$(awk -v min=20000 -v max=30000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
    sed -i '/Port 21/d' /etc/proftpd/proftpd.conf
    echo "Port $Port_FTP" >> /etc/proftpd/proftpd.conf
    echo "Port ftp : $Port_FTP" >> resume.txt
}

changePortMysql()
{
    checkService=$(service mysql status | grep "MariaDB")
    Port_DB=$(awk -v min=30000 -v max=40000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
    if [ "$checkService" != "" ]
    then
        echo "HEHO COUCOUCOUCOCUOCUCOUCOUCOUC"
        sed -i -e "s/port = 3306/port = $Port_DB/g" /etc/mysql/mariadb.conf.d/50-server.cnf
    else
        sed -i -e "s/port = 3306/port = $Port_DB/g" /etc/mysql/my.cnf
    fi
    echo "Port mysql : $Port_DB" >> resume.txt
}

disableRootSSH()
{
    apt install -y openssh-server
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

    sed -i '/#PubkeyAuthentication yes/d' $FILE_SSH
    echo "PubkeyAuthentication yes" >> $FILE_SSH
    sed -i '/#PasswordAuthentication yes/d' $FILE_SSH
    echo "PasswordAuthentication no" >> $FILE_SSH

    service ssh restart
    service ssh restart
}

configureFail2Ban()
{
    # Installation
    apt-get install -y fail2ban

    # Bantime => 1H
    sed -i -e "s/bantime = 10m/bantime = 3600/g" /etc/fail2ban/jail.conf

    # MaxRetry => 3
    sed -i -e "s/maxretry = 3/maxretry = 3/g" /etc/fail2ban/jail.conf

    # IgnoreIP
    IP_Publique=$(wget -qO- icanhazip.com)
    sed -i '/#ignoreip /d' /etc/fail2ban/jail.conf
    sed -i '/ignoreip/a\$IP_Publique' /etc/fail2ban/jail.conf

    # Restart service
    service fail2ban restart
}

configureVPN()
{
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh
    AUTO_INSTALL=y ./openvpn-install.sh
}

wantVPN="undefined"
while [ "$wantVPN" != "y" ] && [ "$wantVPN" != "n" ]
do
    echo "Voulez-vous installer un serveur VPN sur votre machine ? [y/n]"
    read wantVPN
    echo $wantVPN
done


changeRootPassword
changePortSSH
changePortFTP
changePortMysql
configureFail2Ban
if [ "$wantVPN" = "y" ]
then
    configureVPN
fi
