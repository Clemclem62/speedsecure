#!/bin/bash

changeRootPassword()
{
    echo "je change le mdp"
    # apt-get install -y pwgen
    # password_root=$(pwgen 13 1)
    # echo "root:$password_root" | chpassw
    # echo "Votre mot de pass root est $password_root"
    # echo "Votre mot de pass root est $password_root" >> resume.txt
}

changePortSSH()
{
    echo "check $1"
    #Supprimer l'ancien port
    # sed -i '/Port /d' /etc/ssh/sshd_config
    # #Ajouter nouveau port
    # rand=$(awk -v min=10000 -v max=20000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
    # echo "Port $rand" >> /etc/ssh/sshd_config
}


echo "Quel port utiliser pour le serveur SSH ?"
read portSSH
echo "Quel port utiliser pour le serveur FTP ?"
read portFTP
echo "Quel port utiliser pour le serveur mysql ?"
read portMYSQL
wantVPN="undefined"
while [ "$wantVPN" != "y" ] && [ "$wantVPN" != "n" ]
do
    echo "Voulez-vous installer un serveur VPN sur votre machine ? [y/n]"
    read wantVPN
    echo $wantVPN
done

echo "ssh : $portSSH, ftp : $portFTP, mysql : $portMYSQL, veux VPN ? $wantVPN"
changePortSSH "$portSSH"
