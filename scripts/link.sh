#!/bin/sh

set -e

CURRENT_DIR=$(cd "$(dirname "$0")/../"; pwd)
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

make_symlink_under_dir(){
	echo '---> making symlinks under directory :) '
	if [ $# -eq 2 ];then
		_basefile_dir=$1
		_linkfile_dir=$2
	fi

	if [ $# -eq 1 ];then
		_basefile_dir=$1
		_linkfile_dir=$1
	fi

	if [ ! -d "$HOME/$_linkfile_dir" ]; then
		mkdir -p "$HOME/$_linkfile_dir"
	fi

	for file in $(ls "$CURRENT_DIR/$_basefile_dir"); do
		ln -hvfs "$CURRENT_DIR/$_basefile_dir/$file" "$HOME/$_linkfile_dir/$file"
	done
	echo ' '
}

# make symbolic link
make_symlink .zshrc
make_symlink .cursorrules
make_symlink .gitignore
make_symlink .gitconfig
make_symlink .gitconfig.local
make_symlink .config/starship.toml
make_symlink .config/mise/config.toml
make_symlink .czrc
make_symlink changelog.config.js
make_symlink .config/ghostty/config

# make symbolic links under directory
make_symlink_under_dir .claude/commands
make_symlink_under_dir .claude/agents
make_symlink_under_dir .claude/context
make_symlink_under_dir .claude/rules
make_symlink_under_dir .claude/skills