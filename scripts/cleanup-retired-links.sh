#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd "$(dirname "$0")/.." && pwd -P)
home_dir=$HOME
apply=false

usage() {
	printf 'Usage: %s [--apply] [--home-dir DIR]\n' "$0"
	printf 'Default: list retired links owned by this checkout. --apply removes only those links.\n'
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--apply) apply=true; shift ;;
		--home-dir)
			if [ "$#" -lt 2 ]; then usage >&2; exit 2; fi
			home_dir=$2
			shift 2
			;;
		-h|--help) usage; exit 0 ;;
		*) usage >&2; exit 2 ;;
	esac
done

home_dir=$(CDPATH= cd "$home_dir" && pwd -P)
count=0

check_link() {
	link=$home_dir/$1
	source=$repo_dir/$2
	if [ ! -L "$link" ]; then
		if [ -e "$link" ]; then printf 'SKIP (not a symlink): %s\n' "$link"; fi
		return
	fi
	if [ "$(readlink "$link")" != "$source" ]; then
		printf 'SKIP (different target): %s\n' "$link"
		return
	fi
	if [ -e "$source" ] || [ -L "$source" ]; then
		printf 'SKIP (source exists): %s\n' "$link"
		return
	fi
	count=$((count + 1))
	if [ "$apply" = true ]; then
		unlink "$link"
		printf 'REMOVED: %s -> %s\n' "$link" "$source"
	else
		printf 'CHECK: %s -> %s\n' "$link" "$source"
	fi
}

for name in golang-patterns golang-testing golang-build-fixing iterative-retrieval git-branching terraform-validation; do
	check_link ".claude/skills/$name" ".claude/skills/$name"
	check_link ".agents/skills/$name" "agent-assets/skills/$name"
done

for name in go-build-resolver go-reviewer; do
	check_link ".claude/agents/$name.md" ".claude/agents/$name.md"
done

printf 'Matched links: %s (apply=%s)\n' "$count" "$apply"
