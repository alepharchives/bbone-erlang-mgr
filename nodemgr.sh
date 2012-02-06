#!/bin/sh
##############################################################################
#
# Provide a simple UI for configuring Erlang node properties 
#
##############################################################################

# dialog is a utility installed by default on all major Linux distributions.
# But it is good to check availability of dialog utility on your Linux box.

which dialog &> /dev/null

[ $? -ne 0 ]  && echo "Dialog utility is not available, Install it" && exit 1

##############################################################################
#                      Define Functions Here                                 #
##############################################################################

BACKTITLE='BeagleBone Erlang Manager'

###################### deletetempfiles function ##############################

# This function is called by trap command
# For conformation of deletion use rm -fi *.$$

deletetempfiles()
{
    rm -f /tmp/*.$$
}

####################### hostname menu #################################

# Modify the hostname of this board .

hostname_menu()
{
   hostname=`cat /etc/hostname`

   dialog --backtitle "$BACKTITLE" --title "Hostname" \
   --inputbox "\nEnter the name that this board should use to identify itself on the network" \
   12 60 "$hostname" 2> /tmp/temp1.$$

   if [ $? -ne 0 ]
   then
       rm -f /tmp/temp1.$$
       return
   fi

   hostname=`cat /tmp/temp1.$$`
   deletetempfiles                      # remove temporary files

   if [ "$hostname" == "" ]
   then
       dialog --backtitle "$BACKTITLE" \
              --title "Error" \
              --msgbox "The hostname must not be an empty string!" 8 70
       return
   fi

   # Mount the root file system temporarily as writable and 
   # modify the hostname setting.
   mount -o remount,rw /
   echo $hostname > /etc/hostname
   mount -o remount,ro /

   dialog --backtitle "$BACKTITLE" \
          --title "Hostname modified" \
          --msgbox "\nA reboot is required before the change will take effect" 8 70
   return
}

####################### reboot function #################################

# Reboot the board .

reboot_menu()
{
    dialog --backtitle "$BACKTITLE" --title "Are You Sure" \
           --yesno "\nAre you sure that you want to reboot?" 7 70

    if [ $? -eq 0 ]
    then
	clear
	reboot
    fi
}

##############################################################################
#                           MAIN STARTS HERE                                 #
##############################################################################

trap 'deletetempfiles'  EXIT     # calls deletetempfiles function on exit

while :
do

# Dialog utility to display options list

    dialog --clear --backtitle "$BACKTITLE" --title "Main Menu" \
    --menu "Use [UP/DOWN] key to move" 12 60 6 \
    "HOSTNAME"  "Modify this board's hostname" \
    "REBOOT"    "Reboot the board" \
    "EXIT"      "Exit to the shell" 2> /tmp/menuchoices.$$

    retopt=$?
    choice=`cat /tmp/menuchoices.$$`

    case $retopt in

           0) case $choice in

                  HOSTNAME)   hostname_menu ;;
		  REBOOT)     reboot_menu ;;
                  EXIT)       clear; exit 0;;

              esac ;;

          *) clear ; exit ;;
    esac

done 
