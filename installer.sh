#!/bin/bash
####################################################
##                  My Installer                  ##
####################################################
##                                                ##
##                                                ##
## Define Var
RED='\033[0;41;30m'
GREEN='\033[0;42;30m'
STD='\033[0;0;39m'
YELLOW='\033[43;30m'
trap '' SIGINT SIGQUIT SIGTSTP

################################### SHORTCUT ##################################
while [ "$1" != "" ]; do
	case $1 in
		--help|-h)
			echo "Usage: `basename $0` [--reboot|-r|--help|-h|--force|-f|--hostname]"
			echo "  If called without arguments, installs Virtualmin Professional."
			echo
			echo "  --reboot|-r: Reboot the system"
			echo "  --help|-h: This message"
			echo "  --force|-f: Skip confirmation message"
			echo "  --hostname|-host: Set fully qualified hostname"
			echo
			exit 0
		;;
		--reboot|-r)
			mode="reboot"
		;;
		--force|-f|--yes|-y)
			skipyesno=1
		;;
		--hostname|--host)
			shift
			forcehostname=$1
		;;
		*)
		;;
	esac
	shift
done

if [ "$mode" = "reboot" ]; then
	reboot
fi
########### MAIN MENU ###########
function logo {
clear
cat <<EOF

   __    ____  ____
  /__\  (_  _)(  _ \

 /(__)\  _)(_  )   /
(__)(__)(____)(_)\_)
     ____  _  _  ___  ____   __    __    __    ____  ____
    (_  _)( \( )/ __)(_  _) /__\  (  )  (  )  ( ___)(  _ \

     _)(_  )  ( \__ \  )(  /(__)\  )(__  )(__  )__)  )   /
    (____)(_)\_)(___/ (__)(__)(__)(____)(____)(____)(_)\_)
           ___  __  __  ____  ____  ____
          / __)(  )(  )(_  _)(_  _)( ___)
          \__ \ )(__)(  _)(_   )(   )__)
          (___/(______)(____) (__) (____)
EOF
}
function main_menu {
	check_all
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
        * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear;check_all
	esac
	done
 }
#################################
 

############################### SYSTEM FUNCTION ###############################
###############################################################################
function check_all {
        logo;checkos;check_arch
        echo ""
        echo "                       >>>> You OS <<<<"
        echo ">>>>>>>>>>>>>>>>>>" $distro "($architecture) <<<<<<<<<<<<<<<<<"
        echo ""
}
function reboot {
	echo ""
	shutdown -r now
}
function checkos {
	## check RPM
	if [ -f /usr/bin/yum ]; then
			distro=$(sed -n '1{p;q}' /etc/*-release)
			os=$(sed -n '1{p;q}' /etc/*-release | cut -d ' ' -f 1)
	## check DEB
	elif [ -f /usr/bin/apt-get ]; then
			. /etc/os-release
			distro=$PRETTY_NAME
			os=$ID
	else
			OS=$(uname -s)
			VER=$(uname -r)
			distro=$($OS $VER)
	fi
}
function check_arch {
        arch='uname -m'
        if [[ "$(arch)" == "i686" ]]; then
                arch="i386"
                architecture="32 Bit"
        elif [[ "$(arch)" == "x86_64" ]]; then
                arch="x86_64"
                architecture="64 Bit"
        else
                arch="unknown"
                architecture="Unknown"
        fi
}
function check_arch {
        arch='uname -m'
        if [[ "$(arch)" == "i686" ]]; then
                arch="i386"
                architecture="32 Bit"
        elif [[ "$(arch)" == "x86_64" ]]; then
                arch="x86_64"
                architecture="64 Bit"
        else
                arch="unknown"
                architecture="Unknown"
        fi
}
function check_root {
        if (( EUID != 0 )); then
           echo -e "You must be root to do this.          " $C_NO 1>&2
           exit 100
        else
           echo -e "you as root                           " $C_OK
                echo ""
        fi
}
function kvm_check {
        grep -e vmx -e svm /proc/cpuinfo >/dev/null
        if [ $? != 0 ]; then
			kvm=0
        else
            kvm=1
        fi
}
function required_status {
kvm_check
checkos
check_arch
shopt -s nocasematch
# os array
rpm=(redhat fedora centos suse mandrake rhel)
deb=(debian ubuntu xubuntu)
ok_all_os="${GREEN}DEB${STD} & ${GREEN}RHEL${STD}";
ok_all_virt="${GREEN}KVM${STD} & ${GREEN}XEN${STD}";
######### KVM
if [[ "${kvm}" == 1 ]]; then
	ok_all_os_kvm="[ ${GREEN}DEB${STD} ] [ ${GREEN}[RHEL]${STD} ]";
	ok_kvm="${GREEN}KVM${STD}";
	##### KVM 64
	if [[ "${arch}" == "x86_64" ]]; then
		ok_kvm64="${GREEN}KVM 64Bit${STD}";
		ok_kvm32="${RED}Required KVM 32Bit${STD}";
		if [[ "${rpm[*]}" =~ "${os}" ]]; then 
			## RHEL
			ok_kvm_rpm64="${GREEN}RHEL 64Bit With KVM Virt${STD}";
			ok_kvm_rpm32="${YELLOW}Required RHEL OS 32Bit${STD}";
			ok_rpm_64="${GREEN}Required OS With KVM Virt${STD}";
			ok_rpm_32="${YELLOW}Required RHEL 64 OS With KVM${STD}";
			ok_rpm="${GREEN}RHEL OS${STD}";
			ok_kvm_deb64="${RED}Required DEB OS${STD}";
			ok_kvm_deb32="${RED}Required DEB OS 32Bit${STD}";
			ok_deb_64="${RED}Required DEB OS${STD}";
			ok_deb_32="${RED}Required DEB OS 32Bit ${STD}";
			ok_deb="[ ${RED}Required DEB OS${STD} ]"
		elif [[ "${deb[*]}" =~ "${os}" ]]; then 
			## DEB
			ok_kvm_rpm64="${RED}Required RHEL OS${STD}";
			ok_kvm_rpm32="${RED}Required 64 RHEL OS${STD}";
			ok_rpm_64="${RED}Required RHEL OS With KVM Virt${STD}";
			ok_rpm_32="${RED}Required RHEL 64Bit OS With KVM Virt${STD}";
			ok_rpm="${RED}Required RHEL OS${STD}";
			ok_kvm_deb64="${GREEN}Detect DEB 64Bit With KVM${STD}";
			ok_kvm_deb32="${YELLOW}Required DEB 64Bit${STD}";
			ok_deb_64="${GREEN}Detect DEB OS${STD}";
			ok_deb_32="${YELLOW}Required DEB OS 64 Bit With KVM Virt${STD}";
			ok_deb="${GREEN}Detect DEB OS${STD}"
		else
			## KVM 64 Bit with Unknown OS
			ok_kvm_rpm64="${RED}Unknown OS Required RHEL OS${STD}";
			ok_kvm_deb64="${RED}Unknown OS Required RHEL 64 Bit${STD}";
			ok_rpm_64="${RED}Unknown OS Required RHEL${STD}";
			ok_rpm_32="${RED}Unknown OS Required RHEL 64 Bit${STD}";
			ok_rpm="${RED}Unknown OS Required RHEL OS${STD}";
			ok_kvm_deb64="${RED}Unknown OS Required DEB OS${STD}";
			ok_kvm_deb32="${RED}Unknown OS Required DEB OS 64 Bit${STD}";
			ok_deb_64="${RED}Unknown OS Required DEB OS${STD}";
			ok_deb_32="${RED}Unknown OS Required DEB OS 64Bit${STD}";
			ok_deb="${RED}Unknown OS Required DEB OS${STD}"
		fi
	fi
	###### KVM 32
	if [[ "${arch}" == "i386" ]]; then 
		ok_kvm64="${RED}Required KVM 64${STD}";
		ok_kvm32="${GREEN}OK KVM 32${STD}";
		## KVM 32 RPM
		if [[ "${rpm[*]}" =~ "${os}" ]]; then 
			## RPM Status OK
			ok_kvm_rpm64="${RED}Required RPM 64${STD}";			ok_kvm_rpm32="${GREEN}OK${STD}";			ok_rpm_64="${RED}Required RPM 64 KVM${STD}";			ok_rpm_32="${GREEN}Required KVM${STD}";			ok_rpm="${GREEN}OK${STD}";			ok_kvm_deb64="${RED}Required DEB OS 64${STD}";			ok_kvm_deb32="${RED}Required DEB OS${STD}";			ok_deb_64="${RED}Required DEB OS 64${STD}";			ok_deb_32="${RED}Required DEB OS${STD}";			ok_deb="${RED}Required DEB All${STD}"
		elif [[ "${deb[*]}" =~ "${os}" ]]; then 
			## DEB 32 Status OK
			ok_kvm_rpm64="${RED}Required RPM 64${STD}";			ok_kvm_rpm32="${RED}Required RPM 32${STD}";			ok_rpm_64="${RED}Required RPM 64${STD}";			ok_rpm_32="${RED}Required RPM 32${STD}";			ok_rpm="${RED}Required RPM${STD}";			ok_kvm_deb64="${RED}Required DEB 64${STD}";			ok_kvm_deb32="${GREEN}OK DEB 32 KVM${STD}";			ok_deb_64="${RED}Required DEB 64${STD}";			ok_deb_32="${GREEN}OK DEB 32${STD}";			ok_deb="${GREEN}OK DEB All${STD}"
		else
			ok_kvm_rpm64="${RED}Unknown OS Required RPM OS${STD}";			ok_kvm_deb64="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm_64="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm_32="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm="${RED}Unknown OS Required RPM OS${STD}";			ok_kvm_deb64="${RED}Unknown OS Required DEB OS${STD}";			ok_kvm_deb32="${RED}Unknown OS Required DEB OS${STD}";			ok_deb_64="${RED}Unknown OS Required DEB OS${STD}";			ok_deb_32="${RED}Unknown OS Required DEB OS${STD}";			ok_deb="${RED}Unknown OS Required DEB OS${STD}"
		fi
	fi
else
	ok_kvm="${RED}Need KVM${STD}";
	ok_kvm64="${RED}Required KVM 64${STD}";
	ok_kvm32="${RED}Required KVM 32${STD}";
######### NO KVM
	###### NOKVM 64
	if [[ "${arch}" == "x86_64" ]]; then
		if [[ "${rpm[*]}" =~ "${os}" ]]; then 
		## NOKVM RPM 64 Status OK
			ok_kvm_rpm64="${RED}Required RHEl With KVM Virt${STD}";
			ok_kvm_rpm32="${RED}Required RHEL 32Bit With KVM Virt${STD}";
			ok_rpm_64="${GREEN}Detect RHEL 64Bit${STD}";
			ok_rpm_32="${RED}Required RPM 64${STD}";
			ok_rpm="${GREEN}RHEL${STD}";
			ok_kvm_deb64="${RED}Required DEB KVM${STD}";
			ok_kvm_deb32="${RED}Required DEB 32 KVM${STD}";
			ok_deb_64="${RED}Required DEB${STD}";
			ok_deb_32="${RED}Required DEB 32${STD}";
			ok_deb="${RED}Required DEB All${STD}";
		elif [[ "${deb[*]}" =~ "${os}" ]]; then
		## NOKVM DEB 64 Status OK
			ok_kvm_rpm64="${RED}Required RPM KVM${STD}";			ok_kvm_rpm32="${RED}Required RPM 32 KVM${STD}";			ok_rpm_64="${RED}Required RPM${STD}";			ok_rpm_32="${RED}Required RPM 32${STD}";			ok_rpm="${RED}Required RPM OS${STD}";			ok_kvm_deb64="${RED}Required DEB KVM${STD}";			ok_kvm_deb32="${RED}Required DEB 32 KVM${STD}";			ok_deb_64="${GREEN}OK DEB 64${STD}";			ok_deb_32="${YELLOW}Required DEB 64${STD}";			ok_deb="${GREEN}OK DEB All${STD}";
		else
			ok_kvm_rpm64="${RED}Unknown OS Required RPM OS${STD}";			ok_kvm_deb64="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm_64="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm_32="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm="${RED}Unknown OS Required RPM OS${STD}";			ok_kvm_deb64="${RED}Unknown OS Required DEB OS${STD}";			ok_kvm_deb32="${RED}Unknown OS Required DEB OS${STD}";			ok_deb_64="${RED}Unknown OS Required DEB OS${STD}";			ok_deb_32="${RED}Unknown OS Required DEB OS${STD}";			ok_deb="${RED}Unknown OS Required DEB OS${STD}"
		fi
	fi
	###### NOKVM 32
	if [[ "${arch}" == "i386" ]]; then 
		if [[ "${rpm[*]}" =~ "${os}" ]]; then 
		## NOKVM RPM 32 Status OK	
			ok_kvm_rpm64="${RED}Required RPM 64 KVM${STD}";			ok_kvm_rpm32="${RED}Required RPM KVM${STD}";			ok_rpm_64="${RED}Required RPM 64${STD}";			ok_rpm_32="${GREEN}OK RPM 32${STD}";			ok_rpm="${GREEN}OK RPM All${STD}";			ok_kvm_deb64="${RED}Required DEB 64 KVM${STD}";			ok_kvm_deb32="${RED}Required DEB 32 KVM${STD}";			ok_deb_64="${RED}Required DEB 64${STD}";			ok_deb_32="${RED}Required DEB 32${STD}";			ok_deb="${RED}Required DEB All${STD}";
		elif [[ "${deb[*]}" =~ "${os}" ]]; then
			ok_kvm_rpm64="${RED}Required RPM 64 KVM${STD}";			ok_kvm_rpm32="${RED}Required RPM 32 KVM${STD}";			ok_rpm_64="${RED}Required RPM 64${STD}";			ok_rpm_32="${RED}Required RPM${STD}";			ok_rpm="${RED}Required RPM All${STD}";			ok_kvm_deb64="${RED}Required DEB 64 KVM${STD}";			ok_kvm_deb32="${RED}Required DEB KVM${STD}";			ok_deb_64="${RED}Required DEB 64${STD}";			ok_deb_32="${GREEN}OK DEB 32${STD}";			ok_deb="${GREEN}OK DEB All${STD}";
		else
			ok_kvm_rpm64="${RED}Unknown OS Required RPM OS${STD}";			ok_kvm_deb64="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm_64="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm_32="${RED}Unknown OS Required RPM OS${STD}";			ok_rpm="${RED}Unknown OS Required RPM OS${STD}";			ok_kvm_deb64="${RED}Unknown OS Required DEB OS${STD}";			ok_kvm_deb32="${RED}Unknown OS Required DEB OS${STD}";			ok_deb_64="${RED}Unknown OS Required DEB OS${STD}";			ok_deb_32="${RED}Unknown OS Required DEB OS${STD}";			ok_deb="${RED}Unknown OS Required DEB OS${STD}"
		fi

	fi
fi
}
pause(){
  read -p "Press [Enter] key to continue to main menu..." fackEnterKey
}

 
########### SUB MENU ############
function setting_network {
	 clear;check_all
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
		 0 ) clear ;check_all;break;;
		 * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear;check_all
	 esac
	#   }
	 done
}
function installations {
	 clear;check_all;
	 option=0
	 until [ "$option" = "8" ]; do
	 echo -e "  1.) Install Centos Web Panel         "
	 echo -e "  2.) Install Kloxo Official           "
	 echo -e "  3.) Install Kloxo-MR                 "
	 echo -e "  4.) Install Webmin                   "
	 echo -e "  5.) Install Virtualmin               "
	 echo -e "  6.) Install Cloudmin                 "
	 echo -e "  7.) Install Usermin                  "
	 echo -e "  8.) Install Webuzo                   "
	 echo -e "  0.) Return to menu"
	 
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
		 0 ) clear ;check_all;break;;
		 * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear;check_all
	 esac
	#   }
	 done
}
#################################


############################### NETWORK FUNCTION ##############################
###### Setting
function setting_network_ipaddress {
	clear
	echo "setting ip address"
	pause
	clear;check_all
}
function setting_network_hosts {
	clear
	echo "setting ip hosts"
	pause
	clear;check_all
}
function setting_network_hostname {
	clear
	echo "setting ip hostsname"
	pause
	clear;check_all
}
function setting_network_addproxy {
	clear
	echo "setting ip proxy"
	pause
	clear;check_all
}

############################ INSTALLATIONS FUNCTION ###########################
### Start Centos Web Panel
function cwp_msql51 {
	clear
	cwp_cheking
	wget http://centos-webpanel.com/cwp-latest
	sh cwp-latest
	pause
	clear
}
function cwp_mariadb10110 {
	clear
	cwp_cheking
	wget http://centos-webpanel.com/cwp-latest
	sh cwp-latest -d mariadb
	pause
	clear
}
function cwp_cheking {
	echo "Cheking & Update"
	echo "Installing wget"
	yum -y install wget
	echo "Update Package"
	yum -y update
}
function installations_centoswebpanel {
	clear;check_all;
	option=0
	until [ "$option" = "2" ]; do
	echo "  1.) Install Centos Web Panel with MySQL version 5.1"
	echo "  2.) Install Centos Web Panel with MARIA-DB 10.1.10"
	echo "  0.) Back to main Menu"

	echo -n "Enter choice: "
	read option
	echo ""
	case $option in
		1 ) cwp_msql51 ;;
		2 ) cwp_mariadb10110 ;;
		0 ) clear;main_menu;;
		* ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear
	esac
	done
}
### End Centos Web Panel

### Start Kloxo Official
function installations_kloxo-official {
	clear
	echo "Please Wait Installing Kloxo-MR"
	
	pause
	clear
}
### End Kloxo Official

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
	 clear;check_all;
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
		 0 ) clear ;check_all;break;;
		 * ) echo -e "${RED}Error... Please Input the right choice${STD}" && clear;check_all;
	 esac
	#   }
	 done
}
### End Kloxo-MR



### Start ( Web | Virtual | Cloud | User ) min
function webmin_repo_key_cheking {
	clear
	echo "install webmin"
	pause
	clear
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
	clear
	echo "install webmin"
	pause
	clear
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

### Start Webuzo 
function installations_webuzo {
	clear
	echo "Installing Webuzo"
	wget http://files.webuzo.com/install.sh 
	chmod 0755 install.sh
	bash ./install.sh
	pause
	clear
}
#################################

main_menu
