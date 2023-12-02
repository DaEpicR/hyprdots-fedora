#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install pkgs from input list |--/ /-|#
#|-/ /--| Prasanth Rangan                        |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname $(realpath $0))..."
    exit 1
fi

if ! pkg_installed git
    then
    echo "installing dependency git..."
    sudo dnf install git
fi

echo "installing copr..."
./install_copr.sh

install_list="${1:-install_pkg.lst}"

while read pkg
do
    if [ -z $pkg ]
        then
        continue
    fi

    if pkg_installed ${pkg}
        then
        echo "skipping ${pkg}..."

    elif pkg_available ${pkg}
        then
        echo "queueing ${pkg} from dnf..."
        pkg_dnf=`echo $pkg_dnf ${pkg}`

    else
        echo "error: unknown package ${pkg}..."
    fi
done < <( cut -d '#' -f 1 $install_list )

if [ `echo $pkg_dnf | wc -w` -gt 0 ]
    then
    echo "installing $pkg_dnf from dnf..."
    sudo dnf ${use_default} install $pkg_dnf
fi

# python-pyamdgpuinfo
pip install pyamdgpuinfo

# oh-my-zsh-git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# zsh-theme-powerlevel10k-git
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# pokemon-colorscropts
git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts
sudo ./install.sh
cd ..