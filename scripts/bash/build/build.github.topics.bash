#!/bin/env bash
# Copyright 2019 (c) all rights reserved 
# by BuildAPKs https://buildapks.github.io/buildAPKs/
#####################################################################
set -Eeuo pipefail
shopt -s nullglob globstar
export RDR="$HOME/buildAPKs"
. "$RDR"/scripts/bash/init/ushlibs.bash
. "$RDR"/scripts/bash/shlibs/trap.bash 77 78 79 "${0##*/}"
if [[ -z "${1:-}" ]] 
then
	printf "\\e[1;7;38;5;203m%s\\e[1;7;38;5;201m%s\\e[1;7;38;5;203m%s\\e[1;7;38;5;201m%s\\e[1;7;38;5;203m%s\\e[1;7;38;5;201m%s\\e[1;7;38;5;203m%s\\n\\e[0m\\n" "GitHub topic name must be provided;  See " "~/${RDR##*/}/var/conf/TNAMES" " for topic names that build APKs on device with BuildAPKs!  To build all the topic names contained in this file run " "for NAME in \$(cat ~/${RDR##*/}/var/conf/TNAMES) ; do ~/${RDR##*/}/scripts/bash/build/${0##*/} \$NAME ; done" ".  File " "~/${RDR##*/}/var/conf/GAUTH" " has important information should you choose to run this command regarding bandwidth supplied by GitHub. "
	exit 4
fi
if [[ -z "${NUM:-}" ]] 
then
	export NUM="$(date +%s)"
fi
. "$RDR"/scripts/bash/init/ushlibs.bash
. "$RDR"/scripts/bash/shlibs/lock.bash wake.start
. "$RDR"/scripts/bash/shlibs/buildAPKs/bnchn.bash bch.st 
export NUM="$(date +%s)"
export TOPI="${1%/}"
export TOPIC="${TOPI##*/}"
export TOPNAME="${TOPIC,,}"
export JDR="$RDR/sources/github/topics/$TOPIC"
export JID="git.$TOPIC"
export OAUT="$(cat "$RDR/var/conf/GAUTH" | awk 'NR==1')"
export RDR="$HOME/buildAPKs"
export STRING="ERROR FOUND; build.github.topics.bash $1:  CONTINUING... "
printf "\\n\\e[1;38;5;116m%s\\n\\e[0m" "${0##*/}: Beginning BuildAPKs with build.github.topics.bash $1:"
if [[ ! -d "$JDR" ]] 
then
	mkdir -p "$JDR"
fi
cd "$JDR"
if [[ ! -d "$JDR/.config" ]] 
then
	mkdir -p "$JDR/.config"
	printf "%s\\n\\n" "This directory contains results from query for \`AndroidManifest.xml\` files in GitHub $TOPNAME repositores.  " > "$JDR/.config/README.md" 
fi
if [[ ! -f "repos" ]] 
then
	printf "%s\\n" "Downloading GitHub $TOPNAME repositories information:  "
	if [[ "$OAUT" != "" ]] # see $RDR/var/conf/GAUTH file for information 
	then
		curl -u "$OAUT" -H "Accept: application/vnd.github.mercy-preview+json" "https://api.github.com/search/repositories?q=topic:$TOPIC+language:Java" -o repos
	else
		curl -H "Accept: application/vnd.github.mercy-preview+json" "https://api.github.com/search/repositories?q=topic:$TOPIC+language:Java" -o repos
	fi
fi
TARR=($(grep --color=never -v JavaScript repos | grep --color=never -B 5 Java | grep --color=never svn_url | awk -v x=2 '{print $x}' | sed 's/\,//g' | sed 's/\"//g' | sed 's/https\:\/\/github.com\///g' | cut -d\/ -f1)) # creates array of Java language repositories for topic
for NAME in "${TARR[@]}" 
do 
	"$RDR"/scripts/bash/build/build.github.bash "$NAME"
done
. "$RDR"/scripts/bash/shlibs/lock.bash wake.stop
. "$RDR"/scripts/bash/shlibs/buildAPKs/bnchn.bash bch.gt 
# build.github.topics.bash EOF
