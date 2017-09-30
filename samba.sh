#!/bin/bash
newuser(){
	echo 
	echo "Algum usuário de outra máquina vai usar este compartilhamento?[y/n]"
	read MAIS
	MAIS=$(echo "$MAIS" | tr A-Z a-z )
	while [ "$MAIS" = "y" ];do
		echo
		echo "Qual?"
		read USU_LA
		adduser $USU_LA
		smbpasswd -a $USU_LA
		echo "Mais algum usuário para adicinar?[y/n]"
		read MAIS
		MAIS=$(echo "$MAIS" | tr A-Z a-z)
	done
	restarta
}
newdir(){
	MAIS1=$"s"
	while [ "$MAIS1" = "s" ];do
		echo
		echo "Digite o endereço do novo diretório a ser compartilhado"
		read DIRETORIO
		echo 
		echo "Qual o nome que será exibido na rede para este diretório?"
		read NOME_DIR
		echo "" >> /etc/samba/smb.conf
		echo "[$NOME_DIR]" >> /etc/samba/smb.conf
		echo "path = $DIRETORIO" >> /etc/samba/smb.conf
		echo "read only = no" >> /etc/samba/smb.conf
		echo "public = yes" >> /etc/samba/smb.conf
		echo "More Dirs?[y/n]"
		read MAIS1
		MAIS1=$(echo "$MAIS1" | tr A-Z a-z)
	done
	restarta
}
restarta(){
	service nmdb restart > /dev/null
	service smdb restart > /dev/null
}

PRIV=$(id -u)
if [ "$PRIV" != "0" ];then
	echo "More privileges are required"
	exit
fi
CHECK=$( which smbd )
if [ -z "$CHECK" ];then
	echo " Want to install Samba?[y/n]" 
	read INST
	INST=$(echo $INST | tr A-Z a-z)
	if [ "$INST" = "y" ];then 
		apt-get -y install samba
	else	
		exit
	fi
fi

figlet SambaEasy
echo "by DeadRebel"
echo ""

echo "###########################"
echo "1 - New Configs"
echo "2 - Add another dir"
echo "3 - New User"
echo "###########################"
read OPTION

case $OPTION in

1)echo 
  echo
  echo "Nome da rede de compartilhamento?"
  read REDE
  echo 
  echo "Endereço do Dirtório que vai ser compartilhado?"
  read DIRETORIO
  echo 
  echo "Qual o nome que será exibido na rede para esté diretório?"
  read NOME_DIR
  mv /etc/samba/smb.conf /etc/samba/BKPsmb.conf
  echo "[global ]" > /etc/samba/smb.conf
  echo "workgroup = $REDE" >> /etc/samba/smb.conf
  echo "name resolve order = lmhosts wins bcast hos" >> /etc/samba/smb.conf
  echo "" >> /etc/samba/smb.conf
  echo "[$NOME_DIR]" >> /etc/samba/smb.conf
  echo "path = $DIRETORIO" >> /etc/samba/smb.conf
  echo "read only = no" >> /etc/samba/smb.conf
  echo "public = yes" >> /etc/samba/smb.conf
  newuser
  echo "[-] Done"
  echo "[*] Put Up the configs, wait a little"
  exit ;;
2)
  newdir
  echo "[-] Done"
  echo "[*] Updating the new configs" 
  exit ;;

3)
  newuser 
  echo "[-] Done"
  echo "[*] Updating the new config, wait a little"
  exit ;;
*)
  echo "read the instructions, bro"
  exit  ;;
esac
