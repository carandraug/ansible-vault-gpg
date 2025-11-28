#!/bin/sh

## Copyright (C) 2025 David Miguel Susano Pinto
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

## Recreate the encrypted vault password file.
##
## Add the new keys to the pgp-keys directory, list it in the PGP_KEYS
## variable in pgp-vault-password-client-lib.sh, and then run this
## script.  This can only be run by someone that is already capable to
## decrypt the password.


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
    decrypt_password | encrypt_password > "$ENCRYPTED_PASSWORD_FPATH.new"
    mv "$ENCRYPTED_PASSWORD_FPATH.new" "$ENCRYPTED_PASSWORD_FPATH"
}


main "$@"
