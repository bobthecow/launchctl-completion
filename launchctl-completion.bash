#!bash
#
# git-flow-completion
# ===================
# 
# Bash completion support for launchctl (mostly)
# 
# 
# Installation
# ------------
# 
#  1. Install this file. Either:
# 
#     a. Place it in a `bash-completion.d` folder:
# 
#        * /etc/bash-completion.d
#        * /usr/local/etc/bash-completion.d
#        * ~/bash-completion.d
# 
#     b. Or, copy it somewhere (e.g. ~/.launchctl-completion.sh) and put the following line in
#        your .bashrc:
# 
#            source ~/.launchctl-completion.sh
# 
# 
# 
# The Fine Print
# --------------
# 
# Copyright (c) 2010 [Justin Hileman](http://justinhileman.com)
# 
# Distributed under the [MIT License](http://creativecommons.org/licenses/MIT/)


__launchctlcomp_1 ()
{
	local c IFS=' '$'\t'$'\n'
	for c in $1; do
		case "$c$2" in
		--*=*) printf %s$'\n' "$c$2" ;;
		*.)    printf %s$'\n' "$c$2" ;;
		*)     printf %s$'\n' "$c$2 " ;;
		esac
	done
}
__launchctlcomp ()
{
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if [ $# -gt 2 ]; then
		cur="$3"
	fi
	case "$cur" in
	--*=)
		COMPREPLY=()
		;;
	*)
		local IFS=$'\n'
		COMPREPLY=($(compgen -P "${2-}" \
			-W "$(__launchctlcomp_1 "${1-}" "${4-}")" \
			-- "$cur"))
		;;
	esac
}

__launchctl_find_on_cmdline ()
{
	local word subcommand c=1

	while [ $c -lt $COMP_CWORD ]; do
		word="${COMP_WORDS[c]}"
		for subcommand in $1; do
			if [ "$subcommand" = "$word" ]; then
				echo "$subcommand"
				return
			fi
		done
		c=$((++c))
	done
}

__launchctl_list_labels ()
{
	launchctl list | tail -n +2 | grep -v -P "0x[0-9a-fA-F]+\.(anonymous|mach_init)\." | awk '{print $3}'
}

__launchctl_list_started ()
{
	launchctl list | tail -n +2 | grep -v "^-" | grep -v -P "0x[0-9a-fA-F]+\.(anonymous|mach_init)\." | awk '{print $3}'
}

__launchctl_list_stopped ()
{
	launchctl list | tail -n +2 | grep "^-" | grep -v -P "0x[0-9a-fA-F]+\.(anonymous|mach_init)\." | awk '{print $3}'
}

_launchctl ()
{
	local subcommands="load unload submit remove start stop list help"
	local subcommand="$(__launchctl_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__launchctlcomp "$subcommands"
		return
	fi
	
	case "$subcommand" in
	remove|list)
		__launchctlcomp "$(__launchctl_list_labels)"
		return
		;;
	start)
		__launchctlcomp "$(__launchctl_list_stopped)"
		return
		;;
	stop)
		__launchctlcomp "$(__launchctl_list_started)"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

complete -o bashdefault -o default -o nospace -F _launchctl launchctl 2>/dev/null \
	|| complete -o default -o nospace -F _launchctl launchctl
