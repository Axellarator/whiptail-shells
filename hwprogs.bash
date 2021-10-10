#!/bin/bash -x
#if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
#LIN=$(printf '%.s─' $(seq 1 $LEN)) # creates a horizontal line as in <hr>
#if [ -x "$(command -v ${files[$1]})" ]; then # check if program exist somewhere in path

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit; fi

TIT=""; TXT=""; LIN="" OUT=""
WHIPX=0; WHIPY=0; WHIPZ=0

# define file array
files=( "lsbcpu" "lshw" "lspci" "lsscsi" "lsusb" "lsblk" "dmesg" "df" "pydf" "fdisk" "mount" "free" "dmidecode" "cat" "hdparm" "hwinfo" "inxi" )

read WHIPX WHIPY < <(stty size) # Get size of terminal window

let LEN=($WHIPY - 4) 
LIN=$(printf '%.s─' $(seq 1 $LEN)) # now we have a horizontal line

# program's Output in terminal - Check for program first	
TEXT(){
	if [ -x "$(command -v ${files[$1]})" ]; then 
		whiptail --yesno "$3" --scrolltext --title "$2" --yes-button "Back" --no-button "Exit" $WHIPX $WHIPY 3>&1 1>&2 2>&3
		if [ $? -ne 0 ]; then clear; exit; fi	# Leaving the loop
	else 
		whiptail --title "Program not available" --msgbox "File not found. Please install: apt install ${files[$1]}." $WHIPX $WHIPY
	fi
}

LSCPU(){
	TIT="lscpu - CPU Information"
	TXT="lscpu gathers CPU architecture information from sysfs and /proc/cpuinfo. \
	The command output can be optimized for parsing or for easy readability by humans.\
	The information includes, the number of CPUs, threads, cores, sockets, and Non-Uniform Memory Access (NUMA) nodes. \
	There is also information about the CPU caches and cache sharing, family, model, bogoMIPS, byte order, and stepping."
	OUT=$TXT"\n"$LIN"\n"$(lscpu -V)"\n"$LIN"\n"$(lscpu -y)
	
	TEXT $1	"$TIT" "$OUT" 
}

LSHW(){
	TIT="lshw - list Hardware"
	TXT="A general purpose utility, that reports detailed and brief information\
	about multiple different hardware units such as cpu, memory,\
	disk, usb controllers, network adapters etc.\
	lshw extracts the information from different /proc files.\n
	The \"-short\" option generates a brief report about the hardware devices.\
	Scroll down for memory, cpu, disk, network and businfo."
	OUT=$TXT"\n"$LIN"\n"$(lshw -short)"\n"
	OUT=$OUT"\nMemory Information\n"$LIN"\n"$(lshw -short -class memory)"\n"
	OUT=$OUT"\nCPU Information\n"$LIN"\n"$(lshw -class processor)"\n"
	OUT=$OUT"\nDisk Drives\n"$LIN"\n"$(lshw -class disk -class storage -class volume)"\n"
	OUT=$OUT"\nNetwork adapter information\n"$LIN"\n"$(lshw -class network)"\n"
	OUT=$OUT"\nBusinfo Address Details of PCI, USB, SCSI and IDE Devices\n"$LIN"\n"$(lshw -businfo)

	TEXT $1	"$TIT" "$OUT" 
}


LSPCI(){
	TIT="lspci Output"
	TXT="lspci is a utility for displaying information about PCI buses in the system and devices connected to them. \
	It shows a brief list of devices. See your vga adapter, graphics card, network adapter, usb ports, sata controllers, etc."
	OUT=$TXT"\n"$LIN"\n"$(lspci -v)

	TEXT $1 "$TIT" "$OUT" 
}

LSSCSI(){
	TIT="lsscsi Output"
	TXT="Lists out the scsi/sata devices like hard drives and optical drives.Uses information in sysfs \
	to list scsi devices (or hosts) currently attached to the system."
	OUT=$TXT"\n"$LIN"\n"$(lsscsi -c -v)

	TEXT $1 "$TIT" "$OUT" 
}

LSUSB(){
	TIT="lsusb Output"
	TXT="lsusb displays the USB controllers and details about devices connected to them. \
	This includes configuration descriptors for the device's current speed. Class descriptors will be shown, \
	when available, for USB device classes including hub, audio, HID, communications, and chipcard."
	OUT=$TXT"\n"$LIN"\n"$(lsusb -V)"\n"$LIN"\n"$(lsusb -v)

	TEXT $1 "$TIT" "$OUT" 
}

LSBLK(){
	TIT="lsblk Output"
	TXT="lsblk list out information all block devices, \
	which are the hard drive partitions and other storage devices \
	like optical drives and flash drives."
	OUT=$TXT"\n"$LIN"\n"$(lsblk -V)"\n"$LIN"\n"$(lsblk)
	
		TEXT $1 "$TIT" "$OUT" 
}

BTSCR(){
	TIT="dmesg - Bluetooth Output"
	TXT="Some information about your bluetooth devices."
	OUT=$TXT"\n"$LIN"\n"$(hciconfig -a)"\n"$LIN"\n"$(dmesg | grep -i 'blue')
	
	TEXT $1 "$TIT" "$OUT" 

}

DF(){
	TIT="df - Disk Space Information"
	TXT="Reports various partitions, their mount points and the used and available space on each."
	OUT=$TXT"\n"$LIN"\n"$(df -h)

	TEXT $1 "$TIT" "$OUT" 
}

PYDF(){
	TIT="pydf - Disk Space Information"
	TXT="An improved 'df' version. Reports various partitions, \
	their mount points and the used and available space on each."
	OUT=$TXT"\n"$LIN"\n"$(pydf -h -B)

	TEXT $1 "$TIT" "$OUT" 
}

FDISK(){
	TIT="fdisk - Disk Information"
	TXT="Fdisk is a utility to modify partitions on hard drives, \
	and can be used to list out the partition information as well."
	OUT=$TXT"\n"$LIN"\n"$(fdisk -l)

	TEXT $1 "$TIT" "$OUT" 
}

MOUNT(){
	TIT="mount Information"
	TXT="mount is used to mount/unmount and view mounted file systems."
	OUT=$TXT"\n"$LIN"\n"$(mount -v -f)
	
	TEXT $1 "$TIT" "$OUT" 
}

FREE(){
	TIT="free - Memory Disk Information"
	TXT="Free shows the amount of used, free and total amount of RAM on system."
	OUT=$TXT"\n"$LIN"\n"$(free --giga -l -t)

	TEXT $1 "$TIT" "$OUT" 
}

DMICOD(){
	TIT="dmidecode Output"
	TXT="The dmidecode command is different from all other commands. \
	It extracts hardware information by reading data from the SMBIOS data structures \
	(also called DMI tables)."
	OUT=$TXT"\n""\nDMI CPU Information\n"$LIN"\n"$(dmidecode -t processor)"\n"
	OUT=$OUT"\nDMI RAM Information\n"$LIN"\n"$(dmidecode -t memory)"\n"
	OUT=$OUT"\nDMI BIOS Details\n"$LIN"\n"$(dmidecode -t bios)
	
	TEXT $1 "$TIT" "$OUT" 
}

PROC(){ # (13) in array
	TIT="/proc Output"
	TXT="Many of the virtual files in the /proc directory contain information about hardware and configurations.\
	/proc is a virtual filesystem. It contains no 'real' files but runtime system information. It should be regarded \
	as a control and information centre for the kernel. A lot of system utilities are simply calls to files to /proc."
	OUT=$TXT"\n""\n/proc CPU Information\n"$LIN"\n"$(cat /proc/cpuinfo)"\n"
	OUT=$OUT"\n""\n/proc RAM Information\n"$LIN"\n"$(cat /proc/meminfo)"\n"
	OUT=$OUT"\n""\nLinux Kernel Information\n"$LIN"\n"$(cat /proc/version)"\n"
	OUT=$OUT"\n""\n/proc SCSI SATA Information\n"$LIN"\n"$(cat /proc/scsi/scsi)"\n"
	OUT=$OUT"\n""\n/proc partitions Information\n"$LIN"\n"$(cat /proc/partitions)

	TEXT $1 "$TIT" "$OUT" 
}

HDPARM(){
	TIT="hdparm Output"
	TXT="The hdparm command gets information about sata devices like hard disks. \
	hdparm is a command line utility to set and view hardware parameters of hard disk drives"
	OUT=$TXT"\n"$LIN"\n"$(hdparm -i -I /dev/sda)

	TEXT $1 "$TIT" "$OUT" 
}

HWINFO(){
	TIT="hwinfo Output"
	TXT="Use hwinfo to see everything the kernel knows about your CPU, BIOS, USB devices, \
	hard disks, camera, cdrom, chipcard, dsl, dvb, fingerprint, etc."
	OUT=$TXT"\n"$LIN"\n"$(hwinfo --short)

	TEXT $1 "$TIT" "$OUT" 
}

INXI(){
	TIT="inxi Output"
	TXT="Find system and hardware information on Linux. \
	Hardware, CPU, Drivers, Xorg, Desktop, Kernel, GCC version, Processes, RAM usage, and other useful information."
	OUT=$TXT"\n"$LIN"\n"$(inxi -F)

	TEXT $1 "$TIT" "$OUT" 
}

# read WHIPX WHIPY < <(stty size)
# WHIPZ=17

while : ;   # Endless loop
do
	clear
	CHOICES=$(whiptail --title "Hardware information" --menu "Choose your pick" --cancel-button "Done" $WHIPX $WHIPY \
	"1" "lscpu       - List CPU" \
	"2" "lshw        - List Hardware" \
	"3" "lspci       - List PCI" \
	"4" "lsscsi      - List SCSI Devices" \
	"5" "lsusb       - List USB Buses and Device Details" \
	"6" "lsblk       - List Block Devices" \
	"7" "BT Info     - List Bluetooth Devices" \
	"8" "df          - Disk Space" \
	"9" "pydf        - Advanced DF" \
	"10" "fdisk       - Partition Information" \
	"11" "mount       - View mounted File Systems" \
	"12" "free        - Free RAM." \
	"13" "dmidecode   - Hardware Information (DMI Tables)" \
	"14" "/proc Info  -  /proc Directory Information" \
	"15" "hdparm      - List Hard Disk and Parameters" \
	"16" "hwinfo      - List Kernel Details" \
	"17" "inxi        - System and Hardware Details" 3>&1 1>&2 2>&3)

	if [ $? -ne 0 ]; then exit; fi	# Leaving the loop
	
	for CHOICE in $CHOICES; do
		case "$CHOICE" in
			 "1") LSCPU 0 ;;
			 "2") LSHW 1 ;;
			 "3") LSPCI 2 ;;
			 "4") LSSCSI 3 ;;
			 "5") LSUSB 4 ;;
			 "6") LSBLK 5 ;;
			 "7") BTSCR 6 ;;
			 "8") DF 7 ;;
			 "9") PYDF 8 ;;
			"10") FDISK 9 ;;
			"11") MOUNT 10 ;;
			"12") FREE 11 ;;
			"13") DMICOD 12 ;;
			"14") PROC 13 ;;
			"15") HDPARM 14 ;;
			"16") HWINFO 15 ;;
			"17") INXI 16 ;;

			   *) echo "Unsupported item $CHOICE!" >&2
				  exit 1 ;;
		esac
	done
done
