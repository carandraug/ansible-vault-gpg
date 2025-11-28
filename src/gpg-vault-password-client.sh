#!/bin/sh

## Copyright (C) 2025 David Miguel Susano Pinto
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

## This script is an Ansible vault password client.  It reads the
## password from a PGP encrypted file (calls gpg).
##
## This script prints the vault password to stdout.  It is meant to be
## passed as `--vault-password-file` or `--vault-id` option to ansible
## commands (this is done in ansible.cfg so you should not need to do
## it directly).
##
## When an ansible command is called it will call this script like so:
##
##     gpg-vault-password-client.sh --vault-id default
##
## For now, we are not making use of vault IDs/labels.
##
## This file must be named "*-client.sh" and have executable
## permissions for ansible to treat it has as a vault password client.
##
## This script is named gpg-* (and not pgp-* or openpgp-*) because it
## refers to the gpg program it calls.


set -o errexit
set -o nounset
## Use TRACE=1 ./script.sh to enable tracing
if [ "${TRACE-0}" = "1" ]; then
    set -o xtrace
fi


. scripts/vault/gpg-vault-password-client-lib.sh


main() {
    if [ $# -eq 0 ]; then
        ## No arguments, nothing to check.
        :
    elif [ $# -eq 2 ]; then
        ## If called through an ansible command it will be called with
        ## '--vault-id default' (we don't expect anything else).
        if [ "$1" != "--vault-id" ]; then
            echo "First argument is '$1' (expected '--vault-id')" >&2
            exit 1;
        elif [ "$2" != "default" ]; then
            echo "Second argument is '$2' (expected 'default')" >&2
            exit 1;
        fi
    else
        echo "Got $# arguments ('$*') but expected none or 2 ('--vault-id default')" >&2
        exit 1;
    fi

    decrypt_password
}


main "$@"
