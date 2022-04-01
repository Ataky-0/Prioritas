# Prioritas #

Prioritas (from Latin) is an open-source project that uses dynamic renice when switching active windows.
Through an optimization in an "infectious" way it is currently recommended the full use of Prioritas as past windows will have lower priority over time, unless changed in the settings this is the default:

Focus priority (nice) will be set to -10;
Out of focus the priority will be set to 19.

There are ways to control and create exceptions for any windows (currently based on their class names), it is also worth noting that Prioritas will use renice recursively in the process responsible for the window, which means that all child processes will be influenced as well.

Use the no-argument "prioritas" command to refer to a basic help section.

