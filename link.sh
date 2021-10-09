#!/bin/sh

set -e

CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

echo '---> making symlinks :) '
for dotfile in .*; 
do
	case $dotfile in
		.|..|.git|.gitmodules)
			;;
		*)
			echo "$CURRENT_DIR/$dotfile"
			( cd && ln -s -v $CURRENT_DIR/$dotfile ) || true
			;;
	esac
done
