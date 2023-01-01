#!/bin/sh

set -e

CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
HOME=$HOME

make_symlink(){
	echo '---> making symlinks :) '
	if [ $# -eq 1 ];then
		_fromfilename=$1
		_tofilename=$1
	fi
	if [ $# -eq 2 ];then
		_fromfilename=$1
		_tofilename=$2
	fi
	ln -hvfs "$CURRENT_DIR/$_fromfilename" "$HOME/$_tofilename"
}

# make symbolic link
make_symlink .zshrc
make_symlink .gitignore
make_symlink .zshrc
make_symlink .config/starship.toml
make_symlink .config/wezterm/wezterm.lua