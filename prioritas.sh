#!/bin/zsh
#- Dynamic Auto Renicer -#
# Application handler #

exceptionsFolder=/etc/prioritas/exceptions

isPrioritasOn() {
	printf $(pgrep prioritas_d)
}

printHelp() {
	printf "[[ Dynamic Auto Renicer ]]\n\n"
	printf "* start\n	-Start prioritas locally.\n"
	printf "* stop\n	-Stop prioritas.\n"
	printf "* r, restart\n	-Restart prioritas.\n"
	printf "* add_exception, add_ex\n	-Add an exception. (First value is the UNFOCUS nice, second one is the FOCUS nice)\n"
	printf "* remove_exception, rm_ex\n	-Remove an exception.\n		-sw to select a window;\n		-cn to manually provide classname.\n"
}

startPrioritas() {
	if [[ $(isPrioritasOn) ]]
	then
		printf "Prioritas is already running. . .\n"
	else
		if [[ -e /bin/prioritas_d ]]; then
			printf "Starting prioritas. . .\n"
			prioritas_d
		else
			printf "Prioritas not fully installed.\n"
		fi
	fi
}

stopPrioritas() {
	if [[ $(isPrioritasOn) ]]
	then
		printf "Stopping prioritas. . .\n"
		killall prioritas_d &>/dev/null
		tail --pid=$(pgrep prioritas_d) -f /dev/null
		printf "Done\n"
	else
		printf "Prioritas weren't running at all.\n"
	fi
}

add_exception() {
	if [[ $1 ]]
	then
		activeWindow=$(xdotool selectwindow getwindowclassname)
		if [[ $activeWindow && ! -e $exceptionsFolder/$activeWindow ]]
		then
			printf "Adding %s to the exceptions.\n" $activeWindow
			target=$exceptionsFolder/$activeWindow
			touch $target
			printf "UNFOCUSNICE %s\n" $1 >> $target
			if [[ $2 ]]; then
				printf "FOCUSNICE %s\n" $2 >> $target
			fi
			printf "Done.\n"
		else
			printf "No valid or existing window found.\n"
		fi
	else
		printf "Please, provide atleast one value (First value is the UNFOCUS nice, second one is the FOCUS nice.)\n"
	fi
}

remove_exception() {
	if [[ $1 ]]
	then
		case $1 in
			-sw)
				selectedWindow=$(xdotool selectwindow getwindowclassname)
				if [[ $selectedWindow && -e $exceptionsFolder/$selectedWindow ]]
				then
					printf "Removing %s from the exceptions.\n" $selectedWindow
					rm $exceptionsFolder/$selectedWindow && printf "Done.\n"
				else
					printf "No window selected or found in exceptions.\n"
				fi
			;;
			-cn)
				if [[ $2 && -e $exceptionsFolder/$2 ]]
				then
					printf "Removing %s from the exceptions.\n" $2
					rm $exceptionsFolder/$2 && printf "Done.\n"
				else
					printf "No classname passed or found in exceptions.\n"
				fi
			;;
			*)
				printf "Please, provide a valid parameter. (-sw, -cn)\n"
			;;
		esac
	else
		printf "No parameter passed.\nUse -sw to select a window;\nUse -cn to manually provide classname.\n"
	fi
}

if [[ $1 ]]
then
	case $1 in
		start)
			startPrioritas
		;;
		stop)
			stopPrioritas
		;;
		r | restart)
			stopPrioritas && startPrioritas
		;;
		add_exception | add_ex)
			add_exception $2 $3
		;;
		remove_exception | rm_ex)
			remove_exception $2 $3
		;;
		*)
			printHelp
		;;
	esac
else
	printHelp
fi
