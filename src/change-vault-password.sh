#!/bin/sh

## Copyright (C) 2025 David Miguel Susano Pinto
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

## Script to change the ansible vault password.
##
## This takes no argument and will prompt for the new password.  This
## is by design (passwords in the command line may be saved to history
## and appear on the list of processes; passwords in environment
## variables will need to be set from somewhere so have the same
## problem has password in command lines; an argument for a file with
## a password in plain text means password stored in plain text at
## some point in time).
##
## You can confirm the password was set correctly by calling:
##
##     scripts/vault/gpg-vault-password-client.sh
##
## N.B.: you probably do not mean to have a newline at the end of the
## password.


set -o errexit
set -o nounset
## Use TRACE=1 ./script.sh to enable tracing
if [ "${TRACE-0}" = "1" ]; then
    set -o xtrace
fi


. scripts/vault/gpg-vault-password-client-lib.sh


main() {
    if [ $# -ne 0 ]; then
        echo "Expected no arguments but got $# ('$*')" >&2
        exit 1;
    fi

    # TODO: would be nice to have the ability to rekey all encrypted
    # files and encrypted secrets.
    echo "\
This command changes the ansible vault password but does *not* update
the secrets with the new password.  It does *not* rekey encrypted
files and it does *not* re-encrypt variables.  To rekey encrypted
files, look at the 'ansible-vault rekey' command.  To re-encrypt
variables, look into the 'ruamel.yaml' Python package which is the
only one that does round-trip conversion of YAML files.  For both
cases you will need to know where the encrypted content is, Ansible
provides no tools to help you there.
" >&2
    while true; do
        printf "Do you really want to change the password? [y/N]" >&2
        read -r y_or_n
        case $y_or_n in
            ""  ) exit 1;;  # default to "n"
            [Nn]) exit 1;;
            [Yy]) break;;
            *   ) echo "Please answer 'y' or 'n'.";;
        esac
    done


    prompt_and_encrypt_password > "$ENCRYPTED_PASSWORD_FPATH.new"
    mv "$ENCRYPTED_PASSWORD_FPATH.new" "$ENCRYPTED_PASSWORD_FPATH"
}


main "$@"
