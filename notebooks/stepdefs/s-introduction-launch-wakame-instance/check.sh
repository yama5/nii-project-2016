#!/bin/bash

# in the Jupyter notebook, this is run right after doing mussel create
# so give a little time for Wakame-vdc state to change by checking
# ten times, waiting 1 second between each.

for i in $(seq 1 30); do
    ymloutput="$(mussel instance index)"
    (
        # TODO: parse this better!

	if [[ "$ymloutput" != *running* ]] && [[ "$ymloutput" != *initializing* ]]; then
	    echo "ERROR: No instances are running"
	    exit 1
	fi

	if [[ "$ymloutput" != *cpu_cores:\ 2* ]]; then
	    echo "ERROR: Instance must have 2 CPUs"
	    exit 1
	fi

	if [[ "$ymloutput" != *10.0.2.100* ]]; then
	    echo "WARNING: IP address of instance is not 10.0.2.100"
	fi
    )
    rc="$?"
    [ "$rc" = "0" ] && break
    sleep 1
done

if [ "$rc" = "0" ]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi