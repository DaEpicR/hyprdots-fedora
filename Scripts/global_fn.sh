#!/bin/bash
#|---/ /+------------------+---/ /|#
#|--/ /-| Global functions |--/ /-|#
#|-/ /--| Prasanth Rangan  |-/ /--|#
#|/ /---+------------------+/ /---|#

set -e

CloneDir=`dirname "$(dirname "$(realpath "$0")")"`

service_ctl()
{
    local ServChk=$1

    if [[ $(systemctl list-units --all -t service --full --no-legend "${ServChk}.service" | sed 's/^\s*//g' | cut -f1 -d' ') == "${ServChk}.service" ]]
    then
        echo "$ServChk service is already enabled, enjoy..."
    else
        echo "$ServChk service is not running, enabling..."
        sudo systemctl enable ${ServChk}.service
        sudo systemctl start ${ServChk}.service
        echo "$ServChk service enabled, and running..."
    fi
}

pkg_installed()
{
    local PkgIn=$1

    if dnf info installed $PkgIn &> /dev/null
    then
        #echo "${PkgIn} is already installed..."
        return 0
    else
        #echo "${PkgIn} is not installed..."
        return 1
    fi
}

pkg_available()
{
    local PkgIn=$1

    if dnf info $PkgIn &> /dev/null
    then
        #echo "${PkgIn} available in arch repo..."
        return 0
    else
        #echo "${PkgIn} not available in arch repo..."
        return 1
    fi
}

nvidia_detect()
{
    if [ `lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i nvidia | wc -l` -gt 0 ]
    then
        #echo "nvidia card detected..."
        return 0
    else
        #echo "nvidia card not detected..."
        return 1
    fi
}

amd_detect()
{
    if [ `lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i amd | wc -l` -gt 0 ]
    then
        #echo "amd card detected..."
        return 0
    else
        #echo "amd card not detected..."
        return 1
    fi
}

apple_detect()
{
    if [ `lspci -k | grep -A 2 -E "Apple" | wc -l` -gt 0 ]
    then
        #echo "apple detected..."
        return 0
    else
        #echo "apple not detected..."
        return 1
    fi
}

prompt_timer()
{
    set +e
    local timsec=$1
    local msg=$2
    local pread=""
    while [[ $timsec -ge 0 ]] ; do
        echo -ne "\033[0K\r${msg} (${timsec}s) : "
        read -t 1 -n 1 -s promptIn
        [ $? -eq 0 ] && break
        ((timsec--))
    done
    export promptIn
    echo ${promptIn}
    set -e
}