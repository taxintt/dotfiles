#!/bin/sh

set -e

CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
HOME=$HOME

make_symlink(){
	echo '---> making symlinks :) '
	if [ $# -eq 1 ];then
		_basefile=$1
		_linkfile=$1
	fi
	if [ $# -eq 2 ];then
		_basefile=$1
		_linkfile=$2
	fi
	ln -hvfs "$CURRENT_DIR/$_basefile" "$HOME/$_linkfile"
	echo ' '
}

# make symbolic link
make_symlink .zshrc
make_symlink .gitignore
make_symlink .gitconfig
make_symlink .gitconfig.local
make_symlink .zshrc
make_symlink .config/starship.toml
make_symlink .config/wezterm/wezterm.lua