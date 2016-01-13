#!/bin/bash

reportfailed()		      
{
    echo "Script failed...exiting. ($*)" 1>&2
    exit 255
}

[ "$1" != "" ] && fullpath="$(readlink -f $1)"

export ORGCODEDIR="$(cd "$(dirname $(readlink -f "$0"))" && pwd -P)" || reportfailed

if [ "$DATADIR" = "" ]; then
    # Default to putting output in the code directory, which means
    # a separate clone of the repository for each build
    DATADIR="$ORGCODEDIR"
fi
source "$ORGCODEDIR/simple-defaults-for-bashsteps.source"

# avoids errors on first run, but maybe not good to change state
# outside of a step
touch "$DATADIR/datadir.conf"

source "$DATADIR/datadir.conf"
: ${imagesource:=$fullpath}

DATADIR="$DATADIR" "$ORGCODEDIR/ind-steps/build-1box/build-1box.sh"

(
    $starting_group "Set up install Jupyter in VM"
    (
	$starting_group "Set up vmdir"
	(
	    $starting_step "Make vmdir"
	    [ -d "$DATADIR/vmdir" ]
	    $skip_step_if_already_done ; set -e
	    mkdir "$DATADIR/vmdir"
	) ; prev_cmd_failed
	
	DATADIR="$DATADIR/vmdir" \
	       "$ORGCODEDIR/ind-steps/kvmsteps/kvm-setup.sh" \
	       "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz"
    )

    (
	$starting_group "Install Jupyter in the OpenVZ 1box image"
	[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ]
	$skip_group_if_unnecessary

	# TODO: this guard is awkward.
	[ -x "$DATADIR/vmdir/kvm-boot.sh" ] && \
	    "$DATADIR/vmdir/kvm-boot.sh"

	(
	    $starting_step "Do yum install golang"
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
		[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ] || \
		    [ "$("$DATADIR/vmdir/ssh-to-kvm.sh" which go )" = "/usr/bin/go" ]
		}
	    $skip_step_if_already_done ; set -e
	    echo "TODO!!!!"
	    exit 255
	) ; prev_cmd_failed
	
	# TODO: this guard is awkward.
	[ -x "$DATADIR/vmdir/kvm-shutdown-via-ssh.sh" ] && \
	    "$DATADIR/vmdir/kvm-shutdown-via-ssh.sh"
    ) ; prev_cmd_failed

    (
	$starting_step "Make snapshot of image with GO installed"
	[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ]
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmdir/"
	tar czSvf 1box-openvz-w-jupyter.raw.tar.gz 1box-openvz.netfilter.x86_64.raw
    ) ; prev_cmd_failed
)

(
    $starting_step "Expand fresh image from snapshot of image with Jupyter installed"
    [ -f "$DATADIR/vmdir/1box-openvz.netfilter.x86_64.raw" ]
    $skip_step_if_already_done ; set -e
    cd "$DATADIR/vmdir/"
    tar xzSvf 1box-openvz-w-jupyter.raw.tar.gz
) ; prev_cmd_failed

# TODO: this guard is awkward.
[ -x "$DATADIR/vmdir/kvm-boot.sh" ] && \
    "$DATADIR/vmdir/kvm-boot.sh"
