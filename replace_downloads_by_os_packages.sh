#!/bin/sh -eu
# Script to replace downloaded NodeJS packages by the ones from the running
# OS 1.0.0 (c) 2025 Ma_Sys.ma <info@masysma.net>

if ! [ $# = 2 ]; then
	echo "Usage $0 <package1, package2, ...> <expect1, expect2, ...>"
	exit 1
fi

debpkg="$(printf "%s\n" "$1" | tr -d '\n,')"
jspkg="$(for i in $debpkg; do
		dpkg -L "$i"
	done | grep -F /usr/share/nodejs | sort -u)"

printf "%s\n" "$jspkg" | cut -d/ -f 5 | sort -u | grep -vE ^@ | \
	while read -r line; do
		[ -n "$line" ] || continue
		rm -r "node_modules/$line" || true
		ln -s "/usr/share/nodejs/$line" "node_modules/$line" || true
	done

printf "%s\n" "$jspkg" | cut -d/ -f 5,6 | sort -u | \
	grep -E "^@[^/]+\/[^/]+" | while read -r line; do
		rm -r "node_modules/$line" || true
		ln -s "/usr/share/nodejs/$line" "node_modules/$line" || true
	done

printf "%s\n" "$2" | tr ', \t' '\n\n\n' | grep -vE '^$' | sort -u \
							> /tmp/expectpkg$$.txt
find -H node_modules -maxdepth 2 -mindepth 1 -type d | cut -d/ -f 2- | \
	grep -E '^([^@.][^/]+|@[^/]+\/[^/]+)$' | sort -u > /tmp/havepkg$$.txt

echo diff -u /tmp/expectpkg$$.txt /tmp/havepkg$$.txt
echo Check is successful if below output is empty or EXIT0:
diff -u /tmp/expectpkg$$.txt /tmp/havepkg$$.txt
rm /tmp/expectpkg$$.txt /tmp/havepkg$$.txt
echo EXIT0
