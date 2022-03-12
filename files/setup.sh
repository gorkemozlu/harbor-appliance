#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

#set -euo pipefail

# Extract all OVF Properties
DEBUG=$(/setup/getOvfProperty.py "guestinfo.debug")
HOSTNAME=$(/setup/getOvfProperty.py "guestinfo.hostname")
IP_ADDRESS=$(/setup/getOvfProperty.py "guestinfo.ipaddress")
NETMASK=$(/setup/getOvfProperty.py "guestinfo.netmask" | awk -F ' ' '{print $1}')
GATEWAY=$(/setup/getOvfProperty.py "guestinfo.gateway")
DNS_SERVER=$(/setup/getOvfProperty.py "guestinfo.dns")
DNS_DOMAIN=$(/setup/getOvfProperty.py "guestinfo.domain")
NTP_SERVER=$(/setup/getOvfProperty.py "guestinfo.ntp")
ROOT_PASSWORD=$(/setup/getOvfProperty.py "guestinfo.root_password")
HARBOR_PASSWORD=$(/setup/getOvfProperty.py "guestinfo.harbor_password")
DOCKER_NETWORK_CIDR=$(/setup/getOvfProperty.py "guestinfo.docker_network_cidr")

if [[ $? -gt 0 ]]
then
  DEBUG="True"
  HOSTNAME=$(hostname)
  IP_ADDRESS=$(ifconfig | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"|awk 'NR==4{ print; }')
  NETMASK="255.255.255.0"
  GATEWAY=$(ip route show default | awk '/default/ {print $3}')
  DNS_SERVER=$(grep "nameserver" /etc/resolv.conf|awk '{print $2}')
  DNS_DOMAIN="vmw.local"
  NTP_SERVER="time1.google.com"
  ROOT_PASSWORD="VMware1!"
  HARBOR_PASSWORD="VMware1!"
  DOCKER_NETWORK_CIDR="172.17.0.1/16"
fi

if [ -e /root/ran_customization ]; then
    exit
else
	HARBOR_LOG_FILE=/var/log/bootstrap.log
	if [ ${DEBUG} == "True" ]; then
		HARBOR_LOG_FILE=/var/log/bootstrap-debug.log
		set -x
		exec 2>> ${HARBOR_LOG_FILE}
		echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
	fi

	echo -e "\e[92mStarting Customization ..." > /dev/console

	echo -e "\e[92mStarting OS Configuration ..." > /dev/console
	. /setup/setup-01-os.sh

	echo -e "\e[92mStarting Network Configuration ..." > /dev/console
	. /setup/setup-02-network.sh

	echo -e "\e[92mStarting Harbor Configuration ..." > /dev/console
	. /setup/setup-03-harbor.sh

	echo -e "\e[92mCustomization Completed ..." > /dev/console

	# Clear guestinfo.ovfEnv
	vmtoolsd --cmd "info-set guestinfo.ovfEnv NULL"

	# Ensure we don't run customization again
	touch /root/ran_customization
fi