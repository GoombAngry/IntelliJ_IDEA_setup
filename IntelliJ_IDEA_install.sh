#!/bin/bash
# Nombre de la carpeta donde se ubicara el programa
nameDirInstall="IntelliJ_IDEA";
# Convertir texto a minuscula
LowerCase(){
        word=$1;
        echo $word | tr '[:upper:]' '[:lower:]';
}

# Convertir texto a mayuscula
UpperCase(){
        word=$1;
        echo $word | tr '[:lower:]' '[:upper:]';
}

# Limpiar espacios en blanco de una cadena
TrimString(){
	echo "$1" | tr -d ' ';
}

# Opcion no encontrada
NotFoundOption(){
                echo -e "[!] - Args to use script";
                echo -e "### - How to execute Script - ###";
                echo -e "[*] - For install -> sudo ./ScriptName.sh -f fileName";
                echo -e "-a For a user to be able to execute the idea command, it is important to have completed the installation with this script -> sudo ./ScriptName.sh -a username";
}

# Verificando si existe el archivo de la instacion
VerifiedFile(){
	extension=".tar.gz"; # Extension del fichero
	nameFile="$1"; # Name del fichero
	actualDir="$(pwd)"; # Directoro actual
	search="$(find $actualDir -name $nameFile)"; # Busqueda del fichero
	if ! [ "$search" == "" ]; then
		echo "Existe";
	else
		echo "No existe el fichero";
	fi	
}
# Agregara contenido al .bashrc para ejecutar IntelliJ IDEA
AddExecutingToUser(){
	for i in $(ls /home);do
		clear;
		pathIter="/home/$i";
		fileCheckExist="$(find $pathIter -name .bashrc)";
		if ! [ $fileCheckExist == "" ]; then
			read -p "[?] - You want to configure the $i user to launch Intellij Idea Community [s/n]" var;
			while ([ "$var" == "" ]) || ( ! [ "$( TrimString "$(LowerCase $var)")" == "s" ] && ! [ "$( TrimString "$(LowerCase $var)")" == "n" ]) ; do
				clear;
				read -p "[?] - You want to configure the $i user to launch Intellij Idea Community [s/n]" var;
			done
			if [ "$(LowerCase $var)" == "s" ]; then
				echo "[✓] - Configured path for user $i to run IntelliJ IDEA";
				echo -e "# Configuring path to run IntelliJ IDEA by GoombAngry \nIntellij_IDEA=\"$1\"\nexport PATH=\"\$PATH:\$Intellij_IDEA\"" >> $pathIter/.bashrc;
				echo -e "[Desktop Entry]\nVersion=1.0\nName=IntelliJ_IDEA\nComment=Entorno de desarrollo integrado (IDE) para el desarrollo de programas informáticos.\nExec=$1/idea\nIcon=$1/idea.svg\nTerminal=false\nType=Application\nCategories=Utility;Application;" > $pathIter/.local/share/applications/$nameDirInstall.desktop;
				chmod 755 $pathIter/.local/share/applications/$nameDirInstall.desktop;
				echo "[✓] - Changes successfully made to the user $i";
			fi
			
		else
			echo "[!] - The $i user's home folder does not contain .bashrc, the changes will not be applied";
		fi
	done
}
# Buscara si existe un usuario pasado como parametro
SearchUser(){
	result="No existe";
	for user in $(ls /home); do
		if [ "$1" == "$user" ]; then
			result="Existe";
			break
		fi
	done
	echo $result;
}
# Script
# Obtener el id del usuario que ejecuta el script
userid=$EUID;
if [ $userid -eq 0 ];then
	#El Script es ejecutado con sudo
	if [ $# -eq 0 ];then
		NotFoundOption;
	else
		while getopts ":fa" opcion 2>/dev/null; do
			case $opcion in
				f)
				if ! [ "$2" == "" ]; then
					result="$(VerifiedFile $2)";			
					if [ "$result" == "Existe" ];then
						echo "[✓] - File found";
						echo "[?] - Verifying file integrity and decompressing";
						# Nombre del fichero que se va a extraer
						nameFileExtract="$(timeout 4s tar -l -tf $2 | grep '/$' | head -n 1 | awk -F '/' '{print $1}')";
						tar -xvf $2;
						# Cambiar nombre carpetas
						mv $nameFileExtract $nameDirInstall;
						# Mover carpeta a /opt
						mv $nameDirInstall /opt/;
						# Agregando permisos 755 a la carpeta
						chmod 775 -R /opt/$nameDirInstall;
						clear;
						AddExecutingToUser /opt/$nameDirInstall/bin;
						echo "[✓] - The installation completes correctly";
						echo "[*] - IntelliJ_IDEA was installed on /opt";
						echo "[*] - If you want to uninstall it delete the folder";
						echo "[!] - [ ######### IMPORTANT ######### ]";
						echo "[!] - To run Intellij IDEA IDE you must close the terminal, open a new one and run the command \"idea\"";
					else
						echo "[!] - The file does not exists";
					fi
				else
					echo "[!] - You have not indicated the name of the installation file";
				fi
				# Break
				;;
				a)
					if ! [ "$2" == "" ]; then
						result="$(SearchUser $2)";
						if [ "$result" == "Existe" ]; then
							# Comprobar si existe nuestra ruta
							if [ -e "/opt/$nameDirInstall" ];then
								# Comprobar si el usuario dentro de su carpeta home contiene el .bashrc
								fileCheckExist="$(find /home/$2 -name .bashrc)";
								if ! [ $fileCheckExist == "" ]; then
									echo -e "# Configuring path to run IntelliJ IDEA by GoombAngry \nIntellij_IDEA=\"/opt/$nameDirInstall/bin\"\nexport PATH=\"\$PATH:\$Intellij_IDEA\"" >> /home/$2/.bashrc;
									echo "[✓] - Changes successfully made to the user $2";
									echo "[!] - [ ######### IMPORTANT ######### ]";
									echo "[!] - To run Intellij IDEA IDE you must close the terminal, open a new one and run the command \"idea\"";
								else
									echo "[!] - The $2 user's home folder does not contain .bashrc, the changes will not be applied";
								fi	
							else
								echo "[!] - We have not found the installation folder generated by our installation script";
							fi
						else
							echo "[!] - User not found";
						fi
					else
						echo "[!] - You have not indicated a username";
					fi
				# Break
				;;
				?)
				NotFoundOption;
				# Break
				;; 	
			esac
		done
	fi
else	
	echo "[!] - You must run this script as super-user (or run with sudo)";
fi



