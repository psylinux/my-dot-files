#!/bin/sh
#
# To install, just move this file to /usr/local/sbin
#

vmware-hgfsclient | while read folder; do {
    vmwpath="/mnt/hgfs/${folder}"
    if [ ! -d "$vmwpath" ]; then {
        echo "[I] Creating the mounting point" 
        sudo mkdir -p "${vmwpath}"
    }	
    elif [ -z "$(ls -A "$vmwpath")" ]; then {
        echo "[I] Mounting ${folder}   (${vmwpath})"
        sudo umount -f "${vmwpath}" 2>/dev/null
        sudo vmhgfs-fuse -o allow_other -o auto_unmount ".host:/${folder}" "${vmwpath}"
    }
    fi
}
done
