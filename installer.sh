#!/bin/bash
####################################################
##                  My Installer                  ##
####################################################
##                                                ##
##                                                ##
# Define variables
RED='\033[0;41;30m'
STD='\033[0;0;39m'
trap '' SIGINT SIGQUIT SIGTSTP
########### MAIN MENU ###########
function main_menu {
	clear
	option=0
	until [ "$option" = "2" ]; do
	echo "  1.) Network Installations"
	echo "  2.) Install Panel"
	echo "  0.) Quit"

	echo -n "Enter choice: "
	read option
	echo ""
	case $option in
		1 ) setting_network ;;
		2 ) installations ;;
		0 ) clear;exit 0;;
		* ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear
	esac
	done
 }
#################################
 
########### SUB MENU ############
pause(){
  read -p "Press [Enter] key to continue to main menu..." fackEnterKey
}

function setting_network {
	clear
	 option=0
	 until [ "$option" = "4" ]; do
	 echo "  1.) Setting IP Address"
	 echo "  2.) Setting Host"
	 echo "  3.) Setting Hostname"
	 echo "  4.) Setting Proxy"
	 echo "  0.) Return to menu"
	 
	 echo -n "Enter choice: "
	 read option
	 echo ""
	 case $option in
		 1 ) setting_network_ipaddress;;
		 2 ) setting_network_hosts;;
		 3 ) setting_network_hostname;;
		 4 ) setting_network_addproxy;;
		 0 ) clear ;break;;
		 * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear
	 esac
	#   }
	 done
}

function installations {
	 clear
	 option=0
	 until [ "$option" = "8" ]; do
	 echo "  1.) Install Centos Web Panel (Centos Only)"
	 echo "  2.) Install Kloxo Official (Centos Only)"
	 echo "  3.) Install Kloxo-MR (Centos Only)"
	 echo "  4.) Install Webmin"
	 echo "  5.) Install Virtualmin"
	 echo "  6.) Install Cloudmin"
	 echo "  7.) Install Usermin"
	 echo "  8.) Install Webuzo"
	 echo "  0.) Return to menu"
	 
	 echo -n "Enter choice: "
	 read option
	 echo ""
	 case $option in
		 1 ) installations_centoswebpanel;;
		 2 ) installations_kloxo-official;;
		 3 ) installations_kloxo-mr;;
		 4 ) installations_webmin;;
		 5 ) installations_virtualmin;;
		 6 ) installations_cloudmin;;
		 7 ) installations_usermin;;
		 8 ) installations_webuzo;;
		 0 ) clear ;break;;
		 * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear
	 esac
	#   }
	 done
}

#################################

######## SCRIPT FUNCTION ########
###### Setting
function setting_network_ipaddress {
	clear
	echo "setting ip address"
	pause
	clear
}

function setting_network_hosts {
	clear
	echo "setting ip hosts"
	pause
	clear
}

function setting_network_hostname {
	clear
	echo "setting ip hostsname"
	pause
	clear
}

function setting_network_addproxy {
	clear
	echo "setting ip proxy"
	pause
	clear
}

###### Installations 
function installations_centoswebpanel {
	clear
	echo "install centos web panel"
	pause
	clear
}

### Start Kloxo-MR
# Checking Kloxo
function kloxo-mr_checking {
	echo "checking Kloxo-MR old RPM"
	rm -f /tmp/mratwork*
	rm -f mratwork*
	echo "checking certificate"
	update-ca-trust enable
	update-ca-trust extract
}
function kloxo-mr6_install {
	clear
	echo "Please Wait to Install Kloxo-MR 6.5.0.c"
	kloxo-mr_checking
	rpm -Uvh https://github.com/mustafaramadhan/kloxo/raw/rpms/release/neutral/noarch/mratwork-release-0.0.1-1.noarch.rpm
	yum clean all
	yum update mratwork-* -y
	yum install kloxomr -y
	sh /script/upcp -y
	pause
	clear
}
function kloxo-mr7_install {
	clear
	echo "Please Wait to Install Kloxo-MR 7.0.0" 
	kloxo-mr_checking
	rpm -Uvh https://github.com/mustafaramadhan/kloxo/raw/rpms/release/neutral/noarch/mratwork-release-0.0.1-1.noarch.rpm
	yum clean all
	yum update mratwork-* -y
	yum install kloxomr7 -y
	sh /script/upcp -y
	pause
	clear
}
function kloxo-mr_update {
	clear
	echo "install Kloxo-MR Update"
	yum replace kloxomr --replace-with=kloxomr7 -y
	sh /script/upcp -y
	pause
	clear
}
function kloxo-mr_update_from_official {
	clear
	 option=0
	 until [ "$option" = "2" ]; do
	 echo "  1.) Install Kloxo-MR 6.5.0.c"
	 echo "  2.) Install Kloxo-MR 7.0.0"
	 echo "  0.) Return to menu"
	 
	 echo -n "Enter choice: "
	 read option
	 echo ""
	 case $option in
		 1 ) kloxo-mr6_install;;
		 2 ) kloxo-mr7_install;;
		 0 ) clear ;break;;
		 * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear
	 esac
	#   }
	 done
}
function installations_kloxo-mr {
	clear
	 option=0
	 until [ "$option" = "4" ]; do
	 echo "  1.) Install Kloxo-MR 6.5.0.c"
	 echo "  2.) Install Kloxo-MR 7.0.0"
	 echo "  3.) Update Kloxo-MR 6.5.0.c to 7.0.0"
	 echo "  4.) Update From Kloxo Official 6.1.19"
	 echo "  0.) Return to menu"
	 
	 echo -n "Enter choice: "
	 read option
	 echo ""
	 case $option in
		 1 ) kloxo-mr6_install;;
		 2 ) kloxo-mr7_install;;
		 3 ) kloxo-mr_update;;
		 4 ) kloxo-mr_update_from_official;;
		 0 ) clear ;break;;
		 * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear
	 esac
	#   }
	 done
}
### End Kloxo-MR

function installations_kloxo-official {
	clear
	echo "Please Wait Installing Kloxo-MR"
	
	pause
	clear
}

### Start ( Web | Virtual | Cloud | User ) min
function webmin_repo_key_cheking {

}

function yum_webmin_repo_cheking {
	if [ ! -f "$FILE" ]
	then
	   echo "File $FILE does not exist."
	else
	  echo "FIle Found"
	fi

}

function apt_webmin_repo_cheking {

}
function installations_webmin {
	clear
	echo "install webmin"
	pause
	clear
}

function installations_virtualmin {
	clear
	echo "install virtualmin"
	pause
	clear
}

function installations_cloudmin {
	clear
	echo "install cloudmin"
	pause
	clear
}

function installations_usermin {
	clear
	echo "install usermin"
	pause
	clear
}
### End ( Web | Virtual | Cloud | User ) min
function installations_webuzo {
	clear
	echo "install Webuzo"
	pause
	clear
}

#################################


main_menu
