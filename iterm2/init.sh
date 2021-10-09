#!/bin/bash

set -ue

CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
echo "$CURRENT_DIR"

# https://apple.stackexchange.com/questions/111534/iterm2-doesnt-read-com-googlecode-iterm2-plist
ln -fs "$CURRENT_DIR/com.googlecode.iterm2.plist" ~/Library/Preferences/com.googlecode.iterm2.plist