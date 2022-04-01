#!/bin/zsh
#- Dynamic Auto Renicer -#
DELAY=1.4
UNFOCUSNICE=19
FOCUSNICE=-10 ## A value lower than -10 will ask for privilegies.
exceptionsFolder=/etc/prioritas/exceptions

getProcessChildren() {
	echo $(cat /proc/$1/task/*/children)
}

checkException() {
	if [[ -e $exceptionsFolder/$1 ]]
	then
		TARGETCONTENT=$(awk '!/^#/' $exceptionsFolder/$1)
		if [[ -z $TARGETCONTENT ]]
		then
			echo 2
		else
			echo $TARGETCONTENT
		fi
	else
		return 1
	fi
}

getPidsOfProcess() {
	if [[ -d /proc/$1 ]] ## -d stands for "does file exists and it's a directory?"
	then
		List="$(ls -1 /proc/$1/task) $(getProcessChildren $1)"
		keepGoing() {
			for i in $(getProcessChildren $1)
			do
				if [[ -d /proc/$i ]]
				then
					List+=" $(ls -1 /proc/$i/task) $(getProcessChildren $i)"
					keepGoing $i
				fi
			done
		}
		keepGoing $1
		echo ${List}
	fi
}

revertOldPid() {
	if [[ $OldPid -eq 0 || ! $OldPid ]]
	then
		return
	fi
	isException=$(checkException $OldPidClassname)
	customUNFOCUSNICE=$(echo $isException | awk '/^UNFOCUSNICE/{print $2}')
	if [[ $isException && $customUNFOCUSNICE ]]
	then
		renice $customUNFOCUSNICE -p $(getPidsOfProcess $OldPid) &>/dev/null
	else
		renice $UNFOCUSNICE -p $(getPidsOfProcess $OldPid) &>/dev/null
	fi
}

getPidNice() {
	echo $(ps -eo pid,ni | grep $1 | awk '{print $2}')
}

onExit() {
	revertOldPid
	printf "\nExiting. . .\n"
	exit
}

focusOn() {
	isException=$(checkException $3)
	customFOCUSNICE=$(echo $isException | awk '/^FOCUSNICE/{print $NF}')
	if [[ $isException && $customFOCUSNICE && $customFOCUSNICE -gt $FOCUSNICE ]]
	then
		renice $customFOCUSNICE -p $(getPidsOfProcess $2) &>/dev/null
	elif [[ $1 -gt $FOCUSNICE ]]
	then
		renice $FOCUSNICE -p $(getPidsOfProcess $2) &>/dev/null
	fi
}

#getCPU_Usage() {
#	echo $(pidstat -p $1 | awk '{print $8}')
#}

trap "onExit" INT TERM

#OldPid=0
while true
do
	ActiveWindow=$(xdotool getactivewindow) &>/dev/null
	if [[ $ActiveWindow ]]
	then
		{
		ActiveWindowPid=$(xdotool getwindowpid $ActiveWindow)
		ActiveWindowPidNice=$(getPidNice $ActiveWindowPid)
		ActiveWindowClassname=$(xdotool getwindowclassname $ActiveWindow)
		isException=$(checkException $ActiveWindowClassname)
		} &>/dev/null
		if [[ ! $isException && $isException -eq 2 ]] ## Check if it's empty and got error number 2
		then
			echo "High level exception found."
			sleep $DELAY
			continue
		fi
	else
		echo "No active window were found."
		sleep 1
		continue
	fi

	if [[ $ActiveWindowPid -ne $OldPid || ! $OldPid ]]
	then
		revertOldPid
		OldPid=$ActiveWindowPid
		OldPidClassname=$(xdotool getwindowclassname $ActiveWindow)
		focusOn $ActiveWindowPidNice $ActiveWindowPid $ActiveWindowClassname
		echo $OldPidClassname "is on focus now."
	fi
	sleep $DELAY
done
## Fortis Anima ##
